# frozen_string_literal: true

directories.each do |dir|
  # Make test environment idempotent
  bash "Delete #{dir} directory" do
    code "rm -rf /tmp/checksum_#{dir}"
  end

  directory "Create #{dir} directory" do
    path "/tmp/checksum_#{dir}"
  end
end

paths = [
  path_to_data_directory
]

filenames.each do |filename|
  path = File.join(path_to_data_directory, filename)
  paths.append(path)
end

create_directory

# Test files themselves
includes.each do |include|
  algorithms.each do |algorithm|
    paths.each do |path| # Path as innermost loop and directory first avoids false positives for directory tests
      base_name = "#{File.basename(path)}_#{include[0]}_#{include[1]}_#{algorithm}"
      checksum_path = File.join(path_to_checksum_directory, base_name)

      # Check first creation
      checksum_file "#{base_name}_create" do
        source_path path
        target_path checksum_path
        include_path include[0]
        include_metadata include[1]
        checksum_algorithm algorithm
      end

      file File.join(path_to_test_directory, "#{base_name}_create") do
        content 'Just a check'
        action :nothing
        subscribes :create, "checksum_file[#{base_name}_create]", :immediate
      end

      # Check no change
      checksum_file "#{base_name}_none" do
        source_path path
        target_path checksum_path
        include_path include[0]
        include_metadata include[1]
        checksum_algorithm algorithm
      end

      file File.join(path_to_test_directory, "#{base_name}_none") do
        content 'Just a check'
        action :nothing
        subscribes :create, "checksum_file[#{base_name}_none]", :immediate
      end

      # Check content change
      filenames.each do |filename|
        file "#{base_name}_#{filename}" do
          path File.join(path_to_data_directory, filename)
          content base_name
        end
      end

      checksum_file "#{base_name}_content" do
        source_path path
        target_path checksum_path
        include_path include[0]
        include_metadata include[1]
        checksum_algorithm algorithm
      end

      file File.join(path_to_test_directory, "#{base_name}_content") do
        content 'Just a check'
        action :nothing
        subscribes :create, "checksum_file[#{base_name}_content]", :immediate
      end

      # Check modified time change
      bash "#{base_name}_mtime" do
        code "sleep 1 && touch #{path}"
      end

      checksum_file "#{base_name}_mtime" do
        source_path path
        target_path checksum_path
        include_path include[0]
        include_metadata include[1]
        checksum_algorithm algorithm
      end

      file File.join(path_to_test_directory, "#{base_name}_mtime") do
        content 'Just a check'
        action :nothing
        subscribes :create, "checksum_file[#{base_name}_mtime]", :immediate
      end

      # Check permissions change
      bash "#{base_name}_mode1" do
        code "chmod 755 #{path}"
      end

      checksum_file "#{base_name}_mode1" do
        source_path path
        target_path checksum_path
        include_path include[0]
        include_metadata include[1]
        checksum_algorithm algorithm
      end

      bash "#{base_name}_mode2" do
        code "chmod 751 #{path}"
      end

      checksum_file "#{base_name}_mode2" do
        source_path path
        target_path checksum_path
        include_path include[0]
        include_metadata include[1]
        checksum_algorithm algorithm
      end

      file File.join(path_to_test_directory, "#{base_name}_mode") do
        content 'Just a check'
        action :nothing
        subscribes :create, "checksum_file[#{base_name}_mode2]", :immediate
      end

      # Check group change
      bash "#{base_name}_group1" do
        code "chgrp root #{path}"
      end

      checksum_file "#{base_name}_group1" do
        source_path path
        target_path checksum_path
        include_path include[0]
        include_metadata include[1]
        checksum_algorithm algorithm
      end

      bash "#{base_name}_group2" do
        code "chgrp #{other_group} #{path}"
      end

      checksum_file "#{base_name}_group2" do
        source_path path
        target_path checksum_path
        include_path include[0]
        include_metadata include[1]
        checksum_algorithm algorithm
      end

      file File.join(path_to_test_directory, "#{base_name}_group") do
        content 'Just a check'
        action :nothing
        subscribes :create, "checksum_file[#{base_name}_group2]", :immediate
      end
    end
  end
end

user 'bud' do
  shell '/bin/bash'
end

# Test directory content
includes.each do |include|
  algorithms.each do |algorithm|
    base_name = "#{include[0]}_#{include[1]}_#{algorithm}"
    checksum_path = File.join(path_to_checksum_directory, base_name)

    create_directory

    # Check first creation
    checksum_file "#{base_name}_create" do
      source_path path_to_data_directory
      target_path checksum_path
      include_path include[0]
      include_metadata include[1]
      checksum_algorithm algorithm
      owner 'bud'
      group 'bud'
      mode 0o701
    end

    file File.join(path_to_test_directory, "#{base_name}_create") do
      content 'Just a check'
      action :nothing
      subscribes :create, "checksum_file[#{base_name}_create]", :immediate
    end

    # Check no change
    checksum_file "#{base_name}_none" do
      source_path path_to_data_directory
      target_path checksum_path
      include_path include[0]
      include_metadata include[1]
      checksum_algorithm algorithm
      owner 'bud'
      group 'bud'
      mode 0o701
    end

    file File.join(path_to_test_directory, "#{base_name}_none") do
      content 'Just a check'
      action :nothing
      subscribes :create, "checksum_file[#{base_name}_none]", :immediate
    end

    # Check directory modified time change
    reset_directory(path_to_data_directory, checksum_path, include, algorithm)
    bash "#{path_to_data_directory}_dir_mtime" do
      code "sleep 1 && touch #{path_to_data_directory}"
    end

    checksum_file "#{base_name}_dir_mtime" do
      source_path path_to_data_directory
      target_path checksum_path
      include_path include[0]
      include_metadata include[1]
      checksum_algorithm algorithm
      owner 'bud'
      group 'bud'
      mode 0o701
    end

    file File.join(path_to_test_directory, "#{base_name}_dir_mtime") do
      content 'Just a check'
      action :nothing
      subscribes :create, "checksum_file[#{base_name}_dir_mtime]", :immediate
    end

    # Check directory permissions change
    reset_directory(path_to_data_directory, checksum_path, include, algorithm)
    bash "#{path_to_data_directory}_dir_mode" do
      code "chmod 701 #{path_to_data_directory}"
    end

    checksum_file "#{base_name}_dir_mode" do
      source_path path_to_data_directory
      target_path checksum_path
      include_path include[0]
      include_metadata include[1]
      checksum_algorithm algorithm
      owner 'bud'
      group 'bud'
      mode 0o701
    end

    file File.join(path_to_test_directory, "#{base_name}_dir_mode") do
      content 'Just a check'
      action :nothing
      subscribes :create, "checksum_file[#{base_name}_dir_mode]", :immediate
    end

    # Check directory group change
    reset_directory(path_to_data_directory, checksum_path, include, algorithm)
    bash "#{path_to_data_directory}_dir_group" do
      code "chgrp #{other_group} #{path_to_data_directory}"
    end

    checksum_file "#{base_name}_dir_group" do
      source_path path_to_data_directory
      target_path checksum_path
      include_path include[0]
      include_metadata include[1]
      checksum_algorithm algorithm
      owner 'bud'
      group 'bud'
      mode 0o701
    end

    file File.join(path_to_test_directory, "#{base_name}_dir_group") do
      content 'Just a check'
      action :nothing
      subscribes :create, "checksum_file[#{base_name}_dir_group]", :immediate
    end

    # Check content change
    reset_directory(path_to_data_directory, checksum_path, include, algorithm)
    filenames.each do |filename|
      file "#{base_name}_#{filename}" do
        path File.join(path_to_data_directory, filename)
        content base_name
      end
    end

    checksum_file "#{base_name}_content" do
      source_path path_to_data_directory
      target_path checksum_path
      include_path include[0]
      include_metadata include[1]
      checksum_algorithm algorithm
      owner 'bud'
      group 'bud'
      mode 0o701
    end

    file File.join(path_to_test_directory, "#{base_name}_content") do
      content 'Just a check'
      action :nothing
      subscribes :create, "checksum_file[#{base_name}_content]", :immediate
    end

    # Check modified time change
    reset_directory(path_to_data_directory, checksum_path, include, algorithm)
    filenames.each do |filename|
      bash "#{base_name}_mtime" do
        code "sleep 1 && touch #{File.join(path_to_data_directory, filename)}"
      end
    end

    checksum_file "#{base_name}_mtime" do
      source_path path_to_data_directory
      target_path checksum_path
      include_path include[0]
      include_metadata include[1]
      checksum_algorithm algorithm
      owner 'bud'
      group 'bud'
      mode 0o701
    end

    file File.join(path_to_test_directory, "#{base_name}_mtime") do
      content 'Just a check'
      action :nothing
      subscribes :create, "checksum_file[#{base_name}_mtime]", :immediate
    end

    # Check permissions change
    reset_directory(path_to_data_directory, checksum_path, include, algorithm)
    filenames.each do |filename|
      bash "#{base_name}_mode" do
        code "chmod 701 #{File.join(path_to_data_directory, filename)}"
      end
    end

    checksum_file "#{base_name}_mode" do
      source_path path_to_data_directory
      target_path checksum_path
      include_path include[0]
      include_metadata include[1]
      checksum_algorithm algorithm
      owner 'bud'
      group 'bud'
      mode 0o701
    end

    file File.join(path_to_test_directory, "#{base_name}_mode") do
      content 'Just a check'
      action :nothing
      subscribes :create, "checksum_file[#{base_name}_mode]", :immediate
    end

    # Check group change
    reset_directory(path_to_data_directory, checksum_path, include, algorithm)
    filenames.each do |filename|
      bash "#{base_name}_group" do
        code "chgrp #{other_group} #{File.join(path_to_data_directory, filename)}"
      end
    end

    checksum_file "#{base_name}_group" do
      source_path path_to_data_directory
      target_path checksum_path
      include_path include[0]
      include_metadata include[1]
      checksum_algorithm algorithm
      owner 'bud'
      group 'bud'
      mode 0o701
    end

    file File.join(path_to_test_directory, "#{base_name}_group") do
      content 'Just a check'
      action :nothing
      subscribes :create, "checksum_file[#{base_name}_group]", :immediate
    end
  end
end

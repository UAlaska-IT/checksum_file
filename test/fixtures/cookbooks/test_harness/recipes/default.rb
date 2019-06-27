# frozen_string_literal: true

path_to_data_directory = '/tmp/checksum_data'
path_to_checksum_directory = '/tmp/checksum_checksum'
path_to_test_directory = '/tmp/checksum_test'

directories = [
  'data',
  'checksum',
  'test'
]

directories.each do |dir|
  # Make test environment idempotent
  bash "Delete #{dir} directory" do
    code "rm -rf /tmp/checksum_#{dir}"
  end

  directory "Create #{dir} directory" do
    path "/tmp/checksum_#{dir}"
  end
end

filenames = [
  'file_1',
  'file_2'
]

paths = [
  path_to_data_directory
]

filenames.each do |filename|
  path = File.join(path_to_data_directory, filename)
  file path do
    content filename
  end
  paths.append(path)
end

# include_path, include_metadata
includes = [
  [true, true],
  [true, false]
]

algorithms = [
  'md5',
  'sha1'
]

# Test files themselves
paths.each do |path|
  includes.each do |include|
    algorithms.each do |algorithm|
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
    end
  end
end

# Test directory content
includes.each do |include|
  algorithms.each do |algorithm|
    base_name = "#{include[0]}_#{include[1]}_#{algorithm}"
    checksum_path = File.join(path_to_checksum_directory, base_name)

    filenames.each do |filename|
      path = File.join(path_to_data_directory, filename)
      bash "Delete #{base_name} #{filename}" do
        code "rm #{path}"
      end
      file "#{base_name} #{filename}" do
        path path
        content filename
      end
    end

    # Check first creation
    checksum_file "#{base_name}_create" do
      source_path path_to_data_directory
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
      source_path path_to_data_directory
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
      source_path path_to_data_directory
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
    end

    file File.join(path_to_test_directory, "#{base_name}_mtime") do
      content 'Just a check'
      action :nothing
      subscribes :create, "checksum_file[#{base_name}_mtime]", :immediate
    end

    # Check permissions change
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
    end

    file File.join(path_to_test_directory, "#{base_name}_mode") do
      content 'Just a check'
      action :nothing
      subscribes :create, "checksum_file[#{base_name}_mode]", :immediate
    end

    # Check group change
    filenames.each do |filename|
      bash "#{base_name}_group" do
        code "chgrp ssh #{File.join(path_to_data_directory, filename)}"
      end
    end

    checksum_file "#{base_name}_group" do
      source_path path_to_data_directory
      target_path checksum_path
      include_path include[0]
      include_metadata include[1]
      checksum_algorithm algorithm
    end

    file File.join(path_to_test_directory, "#{base_name}_group") do
      content 'Just a check'
      action :nothing
      subscribes :create, "checksum_file[#{base_name}_group]", :immediate
    end
  end
end

# frozen_string_literal: true

path_to_data_directory = '/tmp/checksum_file_data'
path_to_checksum_directory = '/tmp/checksum_checksum_data'
path_to_test_directory = '/tmp/checksum_checksum_data'

# Make test environment idempotent
bash 'Delete data directory' do
  code "rm -rf #{path_to_data_directory}"
end

bash 'Delete checksum directory' do
  code "rm -rf #{path_to_checksum_directory}"
end

bash 'Delete test directory' do
  code "rm -rf #{path_to_test_directory}"
end

directory 'Create data directory' do
  path path_to_data_directory
end

directory 'Create checksum directory' do
  path path_to_checksum_directory
end

directory 'Create test directory' do
  path path_to_test_directory
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
  [true, false],
]

algorithms = [
  'md5',
  'sha1'
]

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

      # Check metadata change
      filenames.each do |filename|
        bash "#{base_name}_metadata" do
          code "touch #{File.join(path_to_data_directory, filename)}"
        end
      end

      checksum_file "#{base_name}_metadata" do
        source_path path
        target_path checksum_path
        include_path include[0]
        include_metadata include[1]
        checksum_algorithm algorithm
      end

      file File.join(path_to_test_directory, "#{base_name}_metadata")do
        content 'Just a check'
        action :nothing
        subscribes :create, "checksum_file[#{base_name}_metadata]", :immediate
      end
    end
  end
end

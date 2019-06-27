# frozen_string_literal: true

# frozen_string_literal: true

path_to_data_directory = '/tmp/checksum_data'
path_to_test_directory = '/tmp/checksum_test'

filenames = [
  'file_1',
  'file_2'
]

paths = [
  path_to_data_directory
]

filenames.each do |filename|
  paths.append(File.join(path_to_data_directory, filename))
end

# Check that we at least have base paths correct
paths.each do |path|
  describe file path do
    it { should exist }
  end
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
includes.each do |include|
  algorithms.each do |algorithm|
    paths.each do |path|
      base_name = "#{File.basename(path)}_#{include[0]}_#{include[1]}_#{algorithm}"

      # Check first creation
      describe file File.join(path_to_test_directory, "#{base_name}_create") do
        it { should exist }
        it { should be_file }
      end

      # Check no change
      describe file File.join(path_to_test_directory, "#{base_name}_none") do
        it { should_not exist }
      end

      # Check content change
      describe file File.join(path_to_test_directory, "#{base_name}_content") do
        it { should exist }
        it { should be_file }
      end

      # Check metadata change
      describe file File.join(path_to_test_directory, "#{base_name}_mtime") do
        if base_name.match?(/(((true|false)_true)|checksum_data)/)
          it { should exist }
          it { should be_file }
        else
          it { should_not exist }
        end
      end
    end
  end
end

# Test directory content
includes.each do |include|
  algorithms.each do |algorithm|
    base_name = "#{include[0]}_#{include[1]}_#{algorithm}"

    # Check first creation
    describe file File.join(path_to_test_directory, "#{base_name}_create") do
      it { should exist }
      it { should be_file }
    end

    # Check no change
    describe file File.join(path_to_test_directory, "#{base_name}_none") do
      it { should_not exist }
    end

    # Check content change
    describe file File.join(path_to_test_directory, "#{base_name}_content") do
      it { should exist }
      it { should be_file }
    end

    # Check modified time change
    describe file File.join(path_to_test_directory, "#{base_name}_mtime") do
      it { should exist }
      it { should be_file }
    end

    # Check permissions change
    describe file File.join(path_to_test_directory, "#{base_name}_mode") do
      it { should exist }
      it { should be_file }
    end

    # Check permissions change
    describe file File.join(path_to_test_directory, "#{base_name}_group") do
      it { should exist }
      it { should be_file }
    end
  end
end

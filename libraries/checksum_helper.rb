# frozen_string_literal: true

# This module implements helpers that are used for checksum resources
module ChecksumFile
  # This module implements helpers that are used for checksum resources
  module Helper
    def bash_out(command)
      stdout, stderr, status = Open3.capture3(command)
      raise "Error: #{stderr}" unless stderr.empty?

      raise "Status: #{status}" if status != 0

      return stdout
    end

    def temp_file_name(path)
      return path.gsub(%r{[\/\s]}, '_')
    end

    def temp_path(path)
      return File.join('/tmp', "#{temp_file_name(path)}.tar")
    end

    # Allow absolute filenames, because we will never extract these
    def generate_tar_file(path_to_file)
      tar_path = temp_path(path_to_file)
      command = "tar --create --format=posix --preserve-permissions --absolute-names --file=#{tar_path} #{path_to_file}"
      bash_out(command)
      return tar_path
    end

    def checksum_command(checksum_algorithm)
      algorithm = checksum_algorithm.downcase
      return 'md5sum' if algorithm == 'md5'

      return 'sha1sum' if algorithm == 'sha1'
    end

    def generate_checksum_and_path(path_to_file, checksum_algorithm)
      command = "#{checksum_command(checksum_algorithm)} #{path_to_file}"
      checksum_and_path = bash_out(command)
      return checksum_and_path
    end

    def separate_checksum_from_path(checksum_and_path)
      splits = checksum_and_path.split(' /tmp/')
      return splits[0].strip
    end

    def generate_checksum_record(source_path, checksum_algorithm)
      path_to_file =
        if File.directory?(source_path)
          generate_tar_file(source_path)
        else
          source_path
        end
      checksum_and_path = generate_checksum_and_path(path_to_file, checksum_algorithm)
      return "#{separate_checksum_from_path(checksum_and_path)}}\n"
    end

    def generate_file_stat(source_path)
      command = "stat -c '%A %U %G %y' #{source_path}"
      stats = bash_out(command)
      return stats
    end

    def generate_file_record(path_to_file, include_path, include_metadata, checksum_algorithm)
      source_path = File.realpath(path_to_file)
      record = generate_checksum_record(source_path, checksum_algorithm)
      record += "#{source_path}\n" if include_path
      record += "#{generate_file_stat(source_path)}\n" if include_metadata
      return record
    end

    def save_record(file_content, new_resource)
      file new_resource.target_path do
        content file_content
        owner new_resource.owner
        group new_resource.group
        mode new_resource.mode
      end
    end

    def save_checksum_file(new_resource)
      file_content = generate_file_record(
        new_resource.source_path,
        new_resource.include_path,
        new_resource.include_metadata,
        new_resource.checksum_algorithm
      )
      save_record(file_content, new_resource)
    end
  end
end

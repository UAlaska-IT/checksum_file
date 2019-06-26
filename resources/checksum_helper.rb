# frozen_string_literal: true

resource_name :checksum_file
provides :checksum_file

default_action :save

property :source_path, String, required: true
property :target_path, String, required: true
property :save_path, [true, false], default: true
property :checksum_algorithm, String, default: 'md5'
property :include_metadata, [true, false], default: true

action :save do
  save_checksum_file_helper(@new_resource)
end

action_class.class_eval do
  include ::ChecksumFile::Helper

  def save_checksum_file_helper(new_resource)
    save_checksum_file(new_resource)
  end
end

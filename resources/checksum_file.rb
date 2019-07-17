# frozen_string_literal: true

resource_name :checksum_file
provides :checksum_file

default_action :save

property :source_path, String, required: true
property :target_path, String, name_property: true
property :owner, String, default: 'root'
property :group, String, default: 'root'
property :mode, [Integer, String], default: 0o644
property :include_path, [true, false], default: true
property :include_metadata, [true, false], default: true
property :checksum_algorithm, ['md5', 'sha1'], default: 'md5'

action :save do
  save_checksum_file(@new_resource)
end

action_class do
  include ChecksumFile::Helper
end

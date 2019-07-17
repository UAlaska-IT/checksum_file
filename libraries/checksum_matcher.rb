# frozen_string_literal: true

if defined?(ChefSpec)
  ChefSpec.define_matcher(:checksum_file)

  def save_checksum_file(resource)
    ChefSpec::Matchers::ResourceMatcher.new(:checksum_file, :save, resource)
  end
end

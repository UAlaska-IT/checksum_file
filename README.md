# Checksum File Cookbook

[![License](https://img.shields.io/github/license/ualaska-it/checksum_file.svg)](https://github.com/ualaska-it/checksum_file)
[![GitHub Tag](https://img.shields.io/github/tag/ualaska-it/checksum_file.svg)](https://github.com/ualaska-it/checksum_file)
[![Build status](https://ci.appveyor.com/api/projects/status/hqu2xohgdgi1b0wx/branch/master?svg=true)](https://ci.appveyor.com/project/UAlaska/checksum-file/branch/master)

__Maintainer: OIT Systems Engineering__ (<ua-oit-se@alaska.edu>)

## Purpose

This cookbook provides a single resource that calculates the checksum of a source file, then writes that checksum and other file data to a target file.
The resource will signal convergence only if the content of the target file changes.

The most common use of the checksum_file resource is to implement idempotence in a more robust fashion than looking at a single file.
One caveat is that this resource takes longer than checking for the creation of a single file, so may be prohibitive for very large directories.
However, the resource typically performs a tar and an md5sum on a target directory, and has been used for source trees of popular open-source projects without significant overhead compared to that of an entire Chef run.
This method is far faster than recursively checking content or even metadata of directory content.

## Requirements

### Chef

This cookbook requires Chef 14+

### Platforms

Supported Platform Families:

* Debian
  * Ubuntu, Mint
* Red Hat Enterprise Linux
  * Amazon, CentOS, Oracle
* Suse

Platforms validated via Test Kitchen:

* Ubuntu
* Debian
* CentOS
* Oracle
* Fedora
* Amazon
* Suse

Notes:

* This cookbook should support any recent Linux variant.

### Dependencies

This cookbook does not constrain its dependencies because it is intended as a utility library.
It should ultimately be used within a wrapper cookbook.

## Resources

This cookbook provides one resource for saving a checksum.

### checksum_file

This resource provides a single action to save a checksum to a file.

__Actions__

One action is provided.

* `:save` - Post condition is that the checksum, and possibly the path and metadata of the source file, are written to the target file.

__Attributes__

This resource has five attributes.

* `source_path` - Required.
The local path to the source file (regular file or directory) for which the checksum is to be calculated.
* `target_path` - Defaults to the name of the resource if not set explicitly.
The local path to which to write the checksum and file information.
* `owner` - Defaults to `root`.
The owner of the target file.
* `group` - Defaults to `root`.
The group of the target file.
* `mode` - Defaults to `0o644`.
The permissions of the target file.
* `include_path` - Defaults to `true`.
Determines if path information is recorded along with the checksum.
If true, a change to the source path (moving the source file) will cause the resource to converge and signal subscribers.
The source path is canonicalized before recording so relative, absolute, double dots, and multiple slashes do not matter.
* `include_metadata` - Defaults to `true`.
For regular files, determines if metadata is recorded along with the checksum.
If true, changing owner, group, mode, or touching the source file will cause the resource to converge and signal subscribers.
For directories, metadata is always included for the directory itself and its content.
Due to a limitation of GNU tar, modification times are only accurate to one second for directory content.
* `checksum_algorithm` - Defaults to `md5`.
The algorithm to use.
Supported values are `md5` and `sha1`, not case sensitive.

## Recipes

This cookbook provides no recipes.

## Examples

Custom resources can be used as below.

```ruby
checksum_file 'Source Checksum' do
  source_path path_to_source_directory
  target_path '/var/chef/cache/source-checksum'
end

# Make sure the build triggers iff the sources change
file path_to_bin_file do
  action :nothing
  subscribes :delete, 'checksum_file[Source Checksum]', :immediate
end

bash 'Compile and Install' do
  code 'make && make install'
  cwd path_to_source_directory
  creates path_to_bin_file
end
```

## Development

See CONTRIBUTING.md and TESTING.md.

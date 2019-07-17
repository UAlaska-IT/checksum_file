# Checksum File Cookbook

[![License](https://img.shields.io/github/license/ualaska-it/checksum_file.svg)](https://github.com/ualaska-it/checksum_file)
[![GitHub Tag](https://img.shields.io/github/tag/ualaska-it/checksum_file.svg)](https://github.com/ualaska-it/checksum_file)
[![Build status](https://ci.appveyor.com/api/projects/status/4t2oix71ik9pd126/branch/master?svg=true)](https://ci.appveyor.com/project/University_of_Alaska_OIT/checksum-file/branch/master)

__Maintainer: OIT Systems Engineering__ (<ua-oit-se@alaska.edu>)

## Purpose

This simple cookbook provides one resource that calculates a checksum, then writes it to a file.
The resource will signal convergence only if the content of the file changes.

The most common use of the checksum_file resource is to implement idempotence in a more robust fashion than looking at a single file.
One caveat is that this resource takes longer than checking for the creation of a single file, so may be prohibitive for very large directories.
However, the resource performs at most a tar and an md5sum on the target, and has been used for source trees of popular open-source projects without significant overhead compared to an entire Chef run.

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

* This cookbook should support any recent Windows or Linux variant.

### Dependencies

This cookbook does not constrain its dependencies because it is intended as a utility library.
It should ultimately be used within a wrapper cookbook.

## Resources

This cookbook provides one resource for saving checksum.

### checksum_file

This resource provides a single action to save a checksum to a file.

__Actions__

One action is provided.

* `:save` - Post condition is that the checksum and path of the source file is written to the target file.

__Attributes__

This resource has five attributes.

* `source_path` - Required.
The local path to the file (regular file or directory) for which the checksum is to be calculated.
* `target_path` - Defaults to the name of the resource if not set explicitly.
The local path to which to write the path and checksum.
* `owner` - Defaults to `root`.
The owner of the target file.
* `group` - Defaults to `root`.
The group of the target file.
* `mode` - Defaults to `0o644`.
The permissions of the target file.
* `include_path` - Defaults to `true`.
Determines if the path information is recorded along with the checksum.
If true, a change to the source path (moving the source file) will cause the resource to converge and signal subscribers.
The source path is canonicalized before recording so relative, absolute, double dots, and multiple slashes do not matter.
* `include_metadata` - Default to `true`.
For regular files, determines if metadata (permissions, times) are recorded along with the checksum.
If true, changing owner, permissions or touching the source file will cause the resource to converge and signal subscribers.
For directories, metadata is always included for the directory itself and its content.
Due to a limitation of GNU tar, modified times are only accurate to one second for directory content.
* `checksum_algorithm` - Default to `md5`.
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

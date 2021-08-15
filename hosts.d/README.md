# Summary

`/etc/hosts` files are a good way to make sure that your computer is not making
requests to sites that you don't actually want to contact. However, they come
with a limitation - the hosts file has to be a single file. This can be
inconvenient if have a lot of sites that you want to add.

Therefore, this utility allows you to split up your hosts into multiple yaml
files, so that you can categorize your links, comment on them, and compile them
into a sorted list after the fact, to append it to your existing hosts file.

## What does the output look like?

This is an example of the contents of a `hosts` file.

```hosts
127.0.0.1 badsite.malware.com
127.0.0.1 badsite2.malware.com
127.0.0.1 spyware.com
```

it acts as a primitive type of DNS - when it detects the given domain name, it
will try to access the given IP address. For sites that you do not actually want
to contact, pointing to 127.0.0.1 (localhost) means that you ask your own
machine for the information. It makes the request fail.

## Usage

Run `deno run --allow-read --allow-write hosts.deno.js` to generate a hosts file
in the build directory.

## Recommended host files

- https://blocklistproject.github.io/Lists/#lists
- https://someonewhocares.org/hosts/


# LuaDNS clone

I was enjoyed to discover [LuaDNS.com](http://www.luadns.com/)
I decide to keep almost the same dns zone lua format and make my own util to got a bind zone format.

# Usage

```
$ ./render exemple.net.lua
or
$ luajit render exemple.net.lua
$ lua5.1 render exemple.net.lua
$ lua5.2 render exemple.net.lua
$ lua5.3 render exemple.net.lua
```

# Difference between LuaDNS format and LuaDNSClone format

 * LuaDNSClone allow to use TTL ans SOA
 * LuaDNSClone should support IPv6 (better than LuaDNS)
 * LuaDNSClone will support DNSSEC/Dane/TLSA/...
 * LuaDNSClone support use of the `"@"` like the `_a` : `a(_a, "1.2.3.4")` equal to `a("@", "1.2.3.4")`

# License

MIT License

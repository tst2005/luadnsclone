
local _hide = {} -- sentinel value
local env

local unpack = unpack or require("table").unpack

local function _cleanargs(...)
	local old = {...}
	local new = {}
	for i,v in ipairs(old) do
		if v ~= _hide then
			new[#new+1] = assert(v)
		end
	end
	return new
end
assert(table.concat(_cleanargs(1, 2, 3), " ") == "1 2 3")
assert(table.concat(_cleanargs(1, _hide, 3), " ") == "1 3")

local function output(...)
	print(table.concat(_cleanargs(...), " "))
end



-- See at http://www.luadns.com/help.html

-- _a = "example.net"

-- @name  = relative name
-- @d    = the current domain (or sub-domain)
local function concat(name, dom)
	assert(dom ~= "@")
	if name == "@" then return name end

	if not dom then
		error("missing argument #2", 2)
	end
	return name .. "." .. dom
end
assert(concat("a", "b")=="a.b")

-----------------------------------------------


-- DNS supports most common Resource Records:
-- A, AAAA, ALIAS, CNAME, FORWARD, MX, NS, PTR, REDIRECT, SOA, SPF, SRV, SSHFP, TXT

-- @name  = relative name
-- @ip    = IPv4 address
-- @ttl   = TTL (default: user default TTL)
local function a(name, ip, ttl)
	if not ttl then
		-- We should set a default value to force to use it... but no, bind support line without TTL.
	end
	output(name, ttl or _hide, "IN A", ip)
end



-- @name  = relative name
-- @ip    = IPv6 address
-- @ttl   = TTL (default: user default TTL)
local function aaaa(name, ip, ttl)
	if ttl then
		-- We should set a default value to force to use it... but no, bind support line without TTL.
	end
	output(name, ttl or _hide, "IN AAAA", ip)
end

-- @name   = relative name
-- @target = target host (fqdn)
-- @ttl    = TTL (default: user default TTL)
local function alias(name, target, ttl)
	assert(name)
	assert(target)
	-- ??
end

-- @name    = relative name
-- @alias   = alias (fqdn)
-- @ttl     = TTL (default: user default TTL)
local function cname(name, alias, ttl)
	assert(name)
	assert(alias)
	output(name, ttl or _hide, "IN CNAME", alias)
end

-- @from    = mailbox name (without domain)
-- @to      = recipient (email address)
-- @ttl     = cache TTL (default: user default TTL)
local function forward(from, to, ttl)
	error("forward not implemented yet", 2)
end

-- @name      = relative name
-- @exchanger = mail exchanger(fqdn)
-- @prio      = priority (default: 0)
-- @ttl       = TTL (default: user default TTL)
local function mx(name, exchanger, prio, ttl)
	assert(name)
	assert(exchanger)
	output(name, ttl or _hide, "IN MX", prio or 0, exchanger)
end

-- @name    = relative name
-- @server  = name server (fqdn)
-- @ttl     = TTL (default: user default TTL)
local function ns(name, server, ttl)
	assert(name)
	assert(server)
	output(name, ttl or _hide, "IN NS", server)
end

-- @name  = relative name
-- @host  = host name (fqdn)
-- @ttl   = TTL (default: user default TTL)
local function ptr(name, host, ttl)
	assert(name)
	assert(host)
	output(name, ttl or _hide, "IN PTR", host)
end

-- @name   = relative name
-- @target = target url
-- @mode   = redirect mode (0=relative, 1=exact, 2=frame, default: 0)
-- @ttl    = cache TTL (default: user default TTL)
local function redirect(name, target, mode, ttl)
	assert(name)
	assert(target)
	--
end

--[[
local function soa(_origin, _ns, _email, _serial, ...)
	local t={"a", "b", "c", "d", "e"}
	for i,v in ipairs({...}) do table.insert(t, v) end
	table.insert(t, "f")
	print(unpack(t))
end
]]--

local tconcat = table.concat

-- Not available in the original LuaDNS
local function soa(_origin, _ns, _email, _serial, _refresh, _retry, _expiration, _minimum)
	local _refresh		= _refresh	or "1d"
	local _retry		= _retry	or "2h"
	local _expiration	= _expiration	or "4w"
	local _minimum		= _minimum	or "1h"

	output(
		_origin, "IN SOA", assert(_ns), assert(_email), tconcat( _cleanargs("(",
			assert(_serial),
			_refresh or "ERROR",
			_retry or "ERROR",
			_expiration or "ERROR",
			_minimum or "ERROR",
		")"), "\n")
	)
end

-- @name    = relative name
-- @text    = text
-- @ttl     = TTL (default: user default TTL)
local function txt(name, text, ttl)
	assert(name)
	output(name, ttl or _hide, "IN TXT", '"'..text..'"')
end

-- @name    = relative name
-- @text    = text
-- @ttl     = TTL (default: user default TTL)
local function spf(name, text, ttl)
	txt(name, text, ttl)
end

-- @name    = relative name
-- @target  = host name(fqdn)
-- @port    = port number
-- @prio    = prio (default: 0)
-- @weight  = weight (default: 0)
-- @ttl     = TTL (default: user default TTL)
local function srv(name, target, port, prio, weight, ttl)
	output( name, ttl or _hide, "IN SRV", prio or 0, weight or 0, port, target)
end
--Note: As in MX records, the target in SRV records must point to hostname with an address record (A or AAAA record). Pointing to a hostname with a CNAME record is not a valid configuration.
-- source: https://en.wikipedia.org/wiki/SRV_record

-- @name        = relative name
-- @algorithm   = algorithm number (1=RSA, 2=DSA, 3=ECDSA)
-- @fp_value    = fingerprint (presented in hex)
-- @fp_type     = fingerprint type (1=SHA-1, 2=SHA-256, default: 1)
-- @ttl         = TTL (default: user default TTL)
local function sshfp(name, algorithm, fp_value, fp_type, ttl)
	--
end

-----------

-- Slave servers
-- Please, configure your ACLs on slave servers to use axfr.luadns.net
-- Add 2 slave servers (ns1.example.net, ns2.example.net)
-- required A and NS records are created automatically
local function slave(name, ip)
	assert(name)

	--FIXME: si name fini par . ok sinon concat(name, _a)

	ns("@", name)
	if ip then
		a(name, ip)
	end
end

----------------------------------------------------------------------------



--[[
; Luadns.com has native support for Bind zone files
; File: example.org.bind
; Zone: example.org

; Default origin is computed from the file name,
; you may change the origin with $ORIGIN directive
; Example:
; $ORIGIN example.org.

; Default TTL is account's [default TTL](https://api.luadns.com/users/edit),
; you may change the default TTL with $TTL directive
; Example:
; $TTL 3600             ; 1 hour

; The system will generate and maintain domain's SOA record automatically,
; SOA records found in *.bind files are simply ignored
example.org.        IN  SOA   ns1.bind.net.   hostmaster.bind.net.  (
                              2012050901  ; serial
                              20m         ; refresh (20 minutes)
                              2m          ; retry (2 minutes)
                              1w          ; expire (1 week)
                              1h          ; minimum (1 hour)
                              )

; Domain NS records are replaced with system name servers
                        NS      ns1.bind.net.
                        NS      ns2.bind.net.
                        NS      ns3.bind.net.
                        NS      ns4.bind.net.

; The rest of records
@                       A       1.1.1.1
@                       MX      5 aspmx.l.google.com.

www                     CNAME   example.org.
mail                    CNAME   ghs.google.com.

; SPF record, see http://www.openspf.org/
@                       TXT     "v=spf1 a mx include:_spf.google.com ~all"

; SIP service available at the host sip.example.com
_sip._udp               SRV     0 0 5060 sip.example.com.

]]--

-- ORIGIN("dom.tld.") Note: with final .
local function ORIGIN(dom)
	--local comm = "; designates the start of this zone file in the namespace"
	--output("$ORIGIN", assert(dom), comm)
	output("$ORIGIN", assert(dom))
	env._a = assert(dom)
end

-- TTL("1h")
local function TTL(ttl)
	--local comm = "; default expiration time of all resource records without their own TTL value"
	--output("$TTL", assert(ttl), comm)
	output("$TTL", assert(ttl))
end

-- SOA(...)
local SOA = assert(soa)

env = {
concat=concat,
a=a, aaaa=aaaa, alias=alias, cname=cname, forward=forward, mx=mx, ns=ns, ptr=ptr, redirect=redirect, soa=soa, spf=spf, srv=srv, sshfp=sshfp, txt=txt,
slave=slave,
}

env.assert = assert
env.error = error
env.print = print

--env.SOA = assert(SOA)
--env.TTL = assert(TTL)

local env_ro = setmetatable({}, {
	__index=env,
	__newindex = function(t, k, ...)
		if k ~= "_a" then
			error("NO GLOBAL CHANGE ALLOWED", 2)
		end
		rawset(t, k, ...)
	end,
})


local _M = {env_rw=assert(env), env_ro=assert(env_ro), env=env_ro, ORIGIN=assert(ORIGIN), TTL=assert(TTL), SOA=assert(SOA), output=assert(output)}
return _M

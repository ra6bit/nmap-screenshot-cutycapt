-- Copyright (C) 2016 Ra6bit & Baker Hamilton
--
-- This program is free software; you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation; version 2 dated June, 1991 or at your option
-- any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
-- GNU General Public License for more details.
--
-- A copy of the GNU General Public License is available in the source tree;
-- if not, write to the Free Software Foundation, Inc.,
-- 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.

-- This script is currently based heavily on the http-screenshot.nse script by Ryan Limm
-- available at https://github.com/SpiderLabs/Nmap-Tools/blob/master/NSE/http-screenshot.nse
-- used here under the GPLv2 license


description = [[
lowacs (local warning and control system) - An nmap based host screenshot browsing system
]]

author = "ra6bit <ra6bit@ra6bit.com> & Baker Hamilton <bhamilt2@bidmc.harvard.edu>"

license = "GPLv2"

categories = {"discovery", "safe"}

-- Updated the NSE Script imports and variable declarations
local shortport = require "shortport"

local stdnse = require "stdnse"

portrule = shortport.http

action = function(host, port)
  -- Create HTML file for readable output
	local f = assert(io.open("lowacs.html", "a"))  

	-- Check to see if ssl is enabled, if it is, this will be set to "ssl"
	local ssl = port.version.service_tunnel

	-- The default URLs will start with http://
	local prefix = "http"

	-- Screenshots will be called screenshot-namp-<IP>:<port>.png
        local filename = "screenshot-nmap-" .. host.ip .. ":" .. port.number .. ".png"
	
	-- If SSL is set on the port, switch the prefix to https
	if ssl == "ssl" then
		prefix = "https"	
	end

	-- Execute the shell command wkhtmltoimage-i386 <url> <filename>
	-- local cmd = "wkhtmltoimage -n " .. prefix .. "://" .. host.ip .. ":" .. port.number .. " " .. filename .. " 2> /dev/null   >/dev/null"
  local cmd = "cutycapt --url=" .. prefix .. "://" .. host.ip .. " --out=" .. filename
	
	local ret = os.execute(cmd)

	-- If the command was successful, print the saved message, otherwise print the fail message
	local result = "failed"

	if ret then
		result = "Saved to " .. filename
		f:write("<table><tr><td><img src=\"./" .. filename .. "\" width=400 height=300></td>")
		f:write("<td>" .. host.ip .. ":" .. port.number .. "</td></tr></table>")
    f:close()
	end

	-- Return the output message
	return stdnse.format_output(true,  result)

end

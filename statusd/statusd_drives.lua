-- Disk drives monitor

-- %drives - list of currently connected drives

-- by Voker57 <voker57@gmail.com>
-- Public domain

local defaults={
    update_interval=500
}

local settings=table.join(statusd.get_config("drives"), defaults)

local drives_timer

local function get_drives()
	local lsres = io.popen("ls /dev/sd* | sort")
	return lsres:lines()
end

local function update_drives()
	local drives_list = get_drives()
	local drive_table = {}
	for drive in drives_list do
 		if drive:match("/([^/]+)$") then
 			local drive_name = drive:match("/([^/]+)$")
 			local drive_base = drive_name:sub(1,3)
 			local drive_partition = drive_name:sub(4,5)
			if drive_table[drive_base] then
				table.insert(drive_table[drive_base], drive_partition)
			else
				drive_table[drive_base] = {drive_partition}
			end
 		end
	end
	local result = ""
	for drive, partitions in pairs(drive_table) do
		result = result..drive
		local parts = ""
 		for k,i in pairs(partitions) do
 			if i ~= "" then
 				parts = parts..i.." "
 			end
 		end 
 		if parts ~= "" then
 			result = result.."["..parts:sub(1,-2).."] "
 		else
 			result = result.." "
 		end
	end
	statusd.inform("drives", result)
	drives_timer:set(settings.update_interval, update_drives)
end

-- Init
drives_timer=statusd.create_timer()
update_drives()
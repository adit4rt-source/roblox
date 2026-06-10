--[[
	Utils.luau
	ModuleScript berisi fungsi-fungsi utility yang bisa digunakan
	di Server maupun Client.
	Lokasi: ReplicatedStorage
]]

local Utils = {}

--- Membuat log dengan format timestamp
--- @param message string -- Pesan yang akan di-log
function Utils.log(message: string)
	local timestamp = os.date("%H:%M:%S")
	print(`[{timestamp}] {message}`)
end

--- Membuat log warning
--- @param message string -- Pesan warning
function Utils.warn(message: string)
	local timestamp = os.date("%H:%M:%S")
	warn(`[{timestamp}] {message}`)
end

--- Lerp (Linear Interpolation) antara dua nilai
--- @param a number -- Nilai awal
--- @param b number -- Nilai akhir
--- @param t number -- Interpolasi (0-1)
--- @return number
function Utils.lerp(a: number, b: number, t: number): number
	return a + (b - a) * math.clamp(t, 0, 1)
end

--- Format angka dengan separator ribuan (1000 -> 1,000)
--- @param n number -- Angka yang akan diformat
--- @return string
function Utils.formatNumber(n: number): string
	local formatted = tostring(math.floor(n))
	local result = ""
	local count = 0

	for i = #formatted, 1, -1 do
		count += 1
		result = string.sub(formatted, i, i) .. result
		if count % 3 == 0 and i > 1 then
			result = "," .. result
		end
	end

	return result
end

--- Membuat warna random
--- @return Color3
function Utils.randomColor(): Color3
	return Color3.fromRGB(
		math.random(0, 255),
		math.random(0, 255),
		math.random(0, 255)
	)
end

--- Cek apakah instance ada dan memiliki tipe tertentu
--- @param instance Instance? -- Instance yang dicek
--- @param className string -- Nama class yang diharapkan
--- @return boolean
function Utils.isInstanceOfClass(instance: Instance?, className: string): boolean
	return instance ~= nil and instance:IsA(className)
end

--- Deep clone sebuah table
--- @param original table -- Table yang akan di-clone
--- @return table
function Utils.deepClone(original: { [any]: any }): { [any]: any }
	local clone = {}
	for key, value in pairs(original) do
		if type(value) == "table" then
			clone[key] = Utils.deepClone(value)
		else
			clone[key] = value
		end
	end
	return clone
end

--- Membuat debounce wrapper untuk sebuah fungsi
--- @param cooldown number -- Waktu cooldown dalam detik
--- @param callback function -- Fungsi yang akan di-debounce
--- @return function
function Utils.debounce(cooldown: number, callback: (...any) -> ()): (...any) -> ()
	local lastCall = 0
	return function(...)
		local now = os.clock()
		if now - lastCall >= cooldown then
			lastCall = now
			callback(...)
		end
	end
end

return Utils

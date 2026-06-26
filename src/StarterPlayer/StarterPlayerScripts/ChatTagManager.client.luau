local TextChatService = game:GetService("TextChatService")
local Players = game:GetService("Players")

-- Fungsi ini akan memanipulasi tampilan pesan chat SEBELUM muncul di layar
TextChatService.OnIncomingMessage = function(message)
	local properties = Instance.new("TextChatMessageProperties")

	-- Pastikan pesan tersebut berasal dari pemain sungguhan
	if message.TextSource then
		local player = Players:GetPlayerByUserId(message.TextSource.UserId)

		if player and player.Character then
			-- Kita "intip" gelar apa yang sedang dipakai di atas kepala karakter mereka
			local head = player.Character:FindFirstChild("Head")
			if head then
				local nametag = head:FindFirstChild("PlayerNametag")
				if nametag and nametag:FindFirstChild("TitleLabel") then

					local gelar = nametag.TitleLabel.Text
					local warna = nametag.TitleLabel.TextColor3

					-- Ubah warna RGB menjadi kode Hex agar bisa dibaca oleh sistem Chat Roblox
					local hexColor = string.format("#%02X%02X%02X", warna.R * 255, warna.G * 255, warna.B * 255)

					-- Gabungkan Gelar + Nama Pemain Asli (PrefixText)
					properties.PrefixText = "<font color='" .. hexColor .. "'>" .. gelar .. "</font> " .. message.PrefixText

				end
			end
		end
	end

	return properties
end
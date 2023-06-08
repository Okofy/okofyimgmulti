require 'unsplash'
require 'telegram/bot'
require 'dotenv/load'

Unsplash.configure do |config|
    config.application_access_key = ENV['UNSPLASH_ACCESS_KEY']
    config.application_secret = ENV['UNSPLASH_SECRET_KEY']
    config.utm_source = ENV['UNSPLASH_UTM_SOURCE']
  end

  token = ENV['TOKEN']


Telegram::Bot::Client.run(token) do |bot|
  bot.listen do |message|
    begin
      case message
      when Telegram::Bot::Types::Message
        buttonx = [
          [Telegram::Bot::Types::InlineKeyboardButton.new(text: 'OKOFY', url: 'https://t.me/okofy')]
        ]
        markup = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: buttonx)

        case message.text
        when '/start'
          # Send the start message with a photo and buttons
          title = "𝐇𝐞𝐲 #{message.from.first_name},\n𝘛𝘩𝘪𝘴 𝘪𝘴 𝘢𝘯 𝘪𝘮𝘢𝘨𝘦 𝘨𝘦𝘯𝘦𝘳𝘢𝘵𝘰𝘳 𝘣𝘰𝘵.\n\n𝙃𝙤𝙬 𝙩𝙤 𝙪𝙨𝙚 𝙞𝙩?\nᴀɴꜱᴡᴇʀ: 𝐉𝐮𝐬𝐭 𝐭𝐲𝐩𝐞 /𝘪𝘮𝘨 𝘞𝘩𝘢𝘵𝘦𝘷𝘦𝘳 𝘺𝘰𝘶 𝘸𝘢𝘯𝘵. \n𝕱𝖔𝖗 𝖊𝖝𝖆𝖒𝖕𝖑𝖊 𝖙𝖞𝖕𝖊 /𝚒𝚖𝚐 𝚃𝚒𝚐𝚎𝚛.  ᴛʜɪꜱ ᴡɪʟʟ ɢɪᴠᴇ ʏᴏᴜ ʀᴇꜱᴜʟᴛꜱ ꜰᴏʀ ᴛɪɢᴇʀ."
          bot.api.send_photo(
            photo: 'https://telegra.ph/file/e5ba8514ae9e3441f7f13.jpg',
            chat_id: message.chat.id,
            caption: title,
            reply_markup: markup
          )
        when /^\/img\s+(.*)/
          query = $1.strip
          results = Unsplash::Photo.search(query)

          if results.any?
            # Send each photo in a separate message
            results.each do |photo|
              photo_url = photo.urls['regular']
              bot.api.send_photo(
                chat_id: message.chat.id,
                photo: photo_url,
                caption: "Here is a result for #{query}\n© Okofy",
                reply_markup: markup
              )
            end
          else
            bot.api.send_message(chat_id: message.chat.id, text: "Sorry, no results found for #{query}")
          end
        end
      when Telegram::Bot::Types::CallbackQuery
        # Handle callback queries if needed
      when Telegram::Bot::Types::InlineQuery
        # Handle inline queries if needed
      end
    rescue Telegram::Bot::Exceptions::ResponseError => e
      next if e.message.include?('Forbidden: bot was blocked by the user')
      puts "An error occurred: #{e.message}"
    end
  end
end

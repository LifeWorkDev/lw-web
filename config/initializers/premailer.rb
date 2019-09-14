# Fix for premailer turning &copy; into © which causes GMail to show the message clipped indicator
Premailer::Rails.config[:output_encoding] = 'US-ASCII'

require 'i18n'

module Jekyll
	I18n.load_path += Dir['_i18n/*.yml']
	
	def self.translate(context, text)
		site = context.registers[:site]
		page = context.registers[:page]
		locale = page['lang'] || site.config['lang']

		if locale
			I18n.locale = locale
			I18n.t(text.strip)
		else
			text.strip
		end
	end
	
	class TranslateTag < Liquid::Tag
		
		def initialize(tag_name, text, tokens)
			super
			@text = text
		end
		
		# Gets a translation of a key according to the page.lang
		def render(context)
			Jekyll.translate context, @text
		end

	end
	
	# Necessary filter when you need multi-language site variables (e.g. menus)
	module TranslateFilter
		
		def translate(input)
			Jekyll.translate @context, input
		end
		
		alias_method :t, :translate
		
	end
end

Liquid::Template.register_tag('t', Jekyll::TranslateTag)
Liquid::Template.register_filter(Jekyll::TranslateFilter)

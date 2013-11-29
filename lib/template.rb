require 'pdfkit'

class Template

  attr_reader :html, :css, :document
  
  def initialize (html = "default.html", css = "default.css")  
    @html = html
    @css = css
    @document = ""
    @cards = {}
    @pages = []
  end

  def <<(details)
    name = details["name"] ||= "No Name #{unique_cards}"
    details["quantity"] ||= 1
    if (@cards.has_key?(name.to_sym)) 
      @cards[name.to_sym]["quantity"] += (details["quantity"] || 1)
    else
      @cards[name.to_sym] = details
    end
    puts "[#{@cards.keys.index(name.to_sym)}] Added #{details["quantity"]} '#{name}' (#{total_cards} total)"
  end
  
  def total_cards
    @cards.values.find_all {|property| property == "quantity"}.reduce(:+)
  end
  
  def unique_cards
    @cards.keys.count
  end
 
  def to_html(destination = "export/exported_#{@html}")
    render_cards
    css_data = File.read(@css)
    export = "<html>
       <head><style type=\"text/css\" media=\"all\">#{css_data}</style>
             <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\"></head>
       <body class=\"content\">
         <table class=\"poker\">
         #{@document}
         </table>
       </body>
       </html>"
    File.open(destination, 'w') { |file| file.write(export) }
    puts "Saved #{@cards_added} cards to #{destination} (#{File.size?(destination)})"
  end
 
  def to_pdf(destination = "export/#{@html}.pdf")
    render_cards
    # Generate the PDF using the HTML we've generated
    kit = PDFKit.new("<html><head><meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\"></head><body class=\"content\">#{@document}</body></html>", :page_size => 'Letter', :print_media_type => true)

    # Add the external cards.css stylesheet to our PDF
    kit.stylesheets << @css

    # Save the PDF to our machine
    kit.to_file(destination)
    puts "Saved #{@cards_added} cards to #{destination} (#{File.size?(destination)})"
  end
  
private
  def render_cards(card_type = "poker")
    # Reset the document property so that we can re-render if necessary
    @document = ""
    # This loop iterates through all the cards that have been added
    cards_rendered = 0
    @cards.each do |name, card_details|
      additional_classes = card_details.delete("css")
      quantity = card_details.delete("quantity")
      card_text = "<h2>#{name.to_s}</h2>"
      card_text += "<dl>"
      card_details.each do |k,v| card_text += "<dt class=\"#{k}\">#{k}</dt><dd class=\"#{k}\">#{v}</dd>"; end
      card_text += "</dl>"
      quantity.times do |i|
        # We need to create a new table every 9 cards
        @document += "<table class=\"#{card_type}\">" if (cards_rendered % 9 == 0)
        # We also need a new table row every 3 cards
        @document += "<tr>" if (cards_rendered % 3 == 0)
        # Insert the card details here
        @document += "<td class=\"card #{additional_classes}\">#{card_text}</td>"
        
        # Increment cards rendered. This may trigger HTML closing tags
        cards_rendered += 1
        @document += "</tr>" if (cards_rendered % 3 == 0)
        @document += "</table>" if (cards_rendered % 9 == 0)
      end
    end
  end
end

require 'yaml'
require 'pdfkit'

# Load the cards from our cards file
cards = YAML.load_file("cards.yml")

# Generate the HTML from our yaml file
html = ""
html << "<html>"
html << "<head><link rel='stylesheet' href='cards.css' type='text/css'></head>"
html << "<body>"

card_count = 1
cards.each do |card, details|
  quantity = details["quantity"]
  quantity.times do |card_instance|
    # Start a new row if it's been 3 cards
    if card_count % 3 == 1
  	  html << "<div class='row'>"
    end

    # Display the card contents
    html << "<div class='card'>"
    html << "  <div class='card-text'>"
    html << "    <span class='bold'>#{card} #{details['cost']}</span>"
    html << "    <p>#{details['text']}</p>"
    html << "  </div>"
    html << "</div>"

    # Close the row if there has been three cards in the row
    if card_count % 3 == 0
      html << "</div>"
    end
    card_count = card_count + 1
  end
end

html << "</body></html>"

File.open('playtest.html', 'w') do |f|
  f.puts html
end

# Generate the PDF using the HTML we've generated
kit = PDFKit.new(html, :page_size => 'Letter', :print_media_type => true)

# Add the external cards.css stylesheet to our PDF
kit.stylesheets << 'cards.css'

# Save the PDF to our machine
file = kit.to_file('playtest.pdf')


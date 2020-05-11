require "httparty"
require "nokogiri"

namespace :scraper do
    task :scrape_users do
        ItemScraper.process_users
    end
end

class ItemScraper
    @users = User.all

    def self.process_users
        users.each do |user|
            process_user(user)
        end
    end

    def self.process_user(user)
        uname = user.name
        uemail = user.email
        products = user.products

        prodInfos = []
        products.each do |pid|
            product = Product.find(pid)
            price, title = process_products(product)
            prodInfos << [price, title, product.name]
        end

        ## TODO: method to send email to user with new prices
        #sendUpdatedPriceEmail(uname, uemail, prodInfos)
    end

    def self.process_product(product)
        url = product.url
        type = product.category
        doc = HTTParty.get(url)
        @page = Nokogiri::HTML(doc)
        # Nokogiri parsing based on site
        # Parsing Nike website
        if type == 'nike'
            price = page.css('.css-b9fpep')[0].children().text[1..-1].to_i
            title = page.css('#pdp_product_title')[0].children().text
        end
        return price, title
    end
end
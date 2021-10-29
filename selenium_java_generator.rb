require 'open-uri'

# use it for give vars and functions name
$counter = 1000;

$array_rules_not_include = ["https://", "about:blank", "_blank", "rel=", "target="]

$special_char_to_match = /[!@#$%^&*().?":{}\[\]|<>;]/

$java_class_name = "SeleniumJavaGenerator"

class SeleniumJavaGenerator
        # check if string has latters
    def self.letters?(string)
        string.chars.any? { |char| ('a'..'z').include? char.downcase }
    end

    # Create java body with selenium import libs 
    def self.create_java_body()
        java_body = "import org.openqa.selenium.JavascriptExecutor;\n"
        java_body += "import org.openqa.selenium.WebDriver;\n"
        java_body += "import org.openqa.selenium.WebElement;\n"
        java_body += "import org.openqa.selenium.support.FindBy;\n\n\n"
        java_body += "public class #{$java_class_name} {\n"
        return java_body
    end

    # Read web page through url
    def self.read_web_page_url(url)
        open(url) do |file|
            read_html_by_lines(file)
        end
    end

    # Read web page through file
    def self.read_web_page_file(file_name)
        File.open(file_name, "a+") do |file|
            allText = file.readlines()
            read_html_by_lines(allText)
        end
    end


    # take html line by line to read
    def self.read_html_by_lines(html_source)
        print_html = create_java_body()
        html_source.each{ |line| 
            if line.match(/(class=|id=)/)
                new_java_code = create_web_element_object(line)
                if new_java_code.length > 0
                    print_html += new_java_code + "\n"
                end
            end
        }
        write_java_class(print_html + "}\n")      
    end


    # Read html line and search for id or class to create object
    def self.create_web_element_object(line)
        newLine = line.scan(/(\S+)=["']?((?:.(?!["']?\s+(?:\S+)=|[>"']))+.)["']?/)
        tag_name = line.scan(/<(\w+)\s+\w+.*?>/)
        java_code = ""
        index = 0
        while index < newLine.size
            current_item = newLine[index]  
            index2 = 0
            while index2 < current_item.size
                $counter += 1
                current_item2 =  newLine[index][index2]
                if current_item2 === ("id")
                    java_code = "//\t" + line + "\n"
                    java_code += check_and_create(newLine[index][index2 + 1], "id", nil)
                elsif current_item2 === ("class")
                    java_code = "//\t" + line + "\n"
                    if tag_name[0] != nil
                        java_code += check_and_create(newLine[index][index2 + 1], "css", tag_name[0][0])
                    end
                end
                index2 += 1 
            end
            index += 1
        end
        return java_code
    end


    def self.check_conditions(tag_check)
        $array_rules_not_include.each { |condition| 
            if tag_check.include?(condition)      
                return false
            end
        }
        return true
    end


    def self.check_and_create(item_class_name, find_type, tag_name)
        collector = ""
        
        if item_class_name != nil
            if  item_class_name.length > 3 &&
                check_conditions(item_class_name) &&
                letters?(item_class_name) &&
                !item_class_name.match($special_char_to_match)
                
                # check if first char is number if return do not continue !
                if item_class_name[0].match(/[0-9]/)
                    return "";
                end
            
                rename_item = item_class_name;
        
                # for css will rename to add tag name in the first name
                if(find_type == "css")
                    rename_item = css_element(item_class_name, tag_name)
                end
        
                
        
                ### <Create on the following format>
                
                # First: @FindBy([type]="[id | class]")
                collector += "\t\t@FindBy(#{find_type}=\"#{rename_item}\")" + "\n"
                
                # Second: Create the object and name it in camel case
                camel_case_item = camel_case(item_class_name, true)
                collector += "\t\tWebElement #{camel_case_item}_#{$counter};" + "\n\n"
        
                # Third: Create function method to start click
                collector += create_java_click_method(camel_case_item)
            end
        end

        return collector
    end


    def self.create_java_click_method(method_name)
        method = "\t\tpublic void clickOn#{camel_case(method_name, false)}_#{$counter}(){\n"
        method += "\t\t\t#{method_name}_#{$counter}.click();\n"
        method += "\t\t}\n\n"
        return method
    end


    # create camel case method
    def self.camel_case(item_name, downcase)
        
        # will take the string and convert to camel case
        new_item_name = item_name.gsub(/\s|\-|\__|\_/, ' ').split.map(&:capitalize)*''
        
        # make first latter down case
        if downcase
            new_item_name[0] = new_item_name[0].downcase
        end

        return new_item_name
    end


    def self.css_element(item_name, tag_name)
        return tag_name + "." + item_name.rstrip.lstrip.gsub(/(\s)+/, '.')
    end

    def self.write_java_class(html)
        puts "... Creating Java Class ...."
        File.open("./#{$java_class_name}.java", "a+") do |file|
            file.truncate(0)
            file << html
        end
    end
end




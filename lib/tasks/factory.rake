# encoding: UTF-8
# Tasks for generating bulk data
namespace :app do
  namespace :factory do
    FIRST_NAMES = %w(Lars Anders Mikael Johan Karl Per Erik Jan Peter Thomas Daniel Fredrik Hans Bengt Mats Andreas Stefan Sven Bo Nils Marcus Magnus Mattias Jonas Niklas Martin Leif Björn Patrik Oskar Ulf Alexander Christer Henrik Joakim Kjell Viktor David Stig Rolf Simon Christoffer Tommy Emil Filip Lennart Robert Gustav Göran Håkan Christian Anton Rickard John Robin Tobias Jonathan Sebastian Kent Jakob William Mohamed Lucas Roger Claes Linus Gunnar Adam Kurt Åke Axel Jesper Jörgen Kenneth Olof Elias Jimmy Arne Rasmus Johnny Isak Albin Dennis Joel Bertil Max Oliver Hugo Pontus Torbjörn Bernt Ludvig Dan Sten Roland Tony Olle Jens Alf Kevin Eva Maria Karin Kristina Lena Kerstin Sara Ingrid Emma Marie Birgitta Malin Jenny Inger Ulla Annika Monica Linda Susanne Elin Hanna Johanna Carina Elisabeth Sofia Katarina Margareta Marianne Anita Helena Emelie Åsa Anette Ida Gunilla Linnéa Camilla Julia Barbro Sandra Siv Ann Anneli Therese Cecilia Josefin Jessica Helen Amanda Gun Lisa Caroline Frida Ulrika Elsa Berit Matilda Maja Madeleine Britt Rebecka Agneta Sofie Pia Rut Yvonne Birgit Ann-Marie Inga Sonja Alice Mona Lina Louise Astrid Ann-Christin Ebba Klara Gunnel Erika Isabelle Britt-Marie Nathalie Moa Alexandra Viktoria Gerd Britta Ellen Irene Lisbeth Pernilla Maj Ella Wilma Felicia Charlotte Ingela Emilia)
    LAST_NAMES = %w(Andersson Johansson Karlsson Nilsson Eriksson Larsson Olsson Persson Svensson Gustafsson Pettersson Jonsson Jansson Hansson Bengtsson Jönsson Lindberg Jakobsson Magnusson Olofsson Lindström Lindqvist Lindgren Axelsson Berg Lundberg Bergström Lundgren Lundqvist Mattsson Lind Berglund Fredriksson Sandberg Henriksson Forsberg Sjöberg Wallin Danielsson Håkansson Engström Eklund Lundin Gunnarsson Holm Fransson Samuelsson Bergman Björk Wikström Isaksson Bergqvist Arvidsson Nyström Holmberg Löfgren Claesson Söderberg Nyberg Blomqvist Mårtensson Nordström Lundström Eliasson Pålsson Björklund Viklund Berggren Sandström Nordin Lund Ström Hermansson Åberg Ekström Holmgren Sundberg Hedlund Dahlberg Hellström Sjögren Abrahamsson Falk Martinsson Andreasson Öberg Blom Månsson Ek Åkesson Strömberg Jonasson Hansen Norberg Sundström Åström Holmqvist Lindholm Sundqvist Ivarsson)

    task students: :environment do
      num = (ENV["num"] || 10).to_i
      1.upto(num) do
        student = FactoryGirl.create(:student, name: "#{FIRST_NAMES.sample} #{LAST_NAMES.sample}")
        puts "New student: #{student.name}"
      end
    end
  end
end

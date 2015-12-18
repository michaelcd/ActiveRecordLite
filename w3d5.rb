# W3D5

## Metaprogramming

class Animal

  def initialize(name)
    @name = name
    @messages_for_tricks = {}

    self.class.known_tricks.each do |trick|
      self.send("message_for_#{trick}=", "NA")
    end
  end

  def sleep
    puts "sleep sleep sleep"
  end

  def eat
    puts "eat eat eat eat"
  end

  def self.known_tricks
    @known_tricks ||= []
  end

  def self.learn_trick(*tricks)
    # self => Animal

    tricks.each do |trick|

      define_method("message_for_#{trick}=") do |message|
        @messages_for_tricks[trick] = message
        # instance_variable_set("@message_for_#{trick}", message)
      end

      define_method(trick) do
        # self => Animal instance
        puts "#{@name} can #{trick.to_s * 3}"

        # message = instance_variable_get("@message_for_#{trick}")
        message = @messages_for_tricks[trick]
        puts message
      end

      self.known_tricks << trick
    end

  end
end

class Cat < Animal
  learn_trick :jump, :sleep

  def initialize(name)
    super
    #
    # set_message_for_jump("NA")
    # set_message_for_sleep("NA")

    Cat.all_cats << self
  end

  def self.all_cats
    # class instance variable
    @all_cats ||= []
  end
end








































###

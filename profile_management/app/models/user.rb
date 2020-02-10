require 'elasticsearch/model'

class User < ApplicationRecord

  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  #one to many relationship between parent and user
  belongs_to :parent, :class_name => 'User', optional: true
  has_many :children, :class_name => 'User', :foreign_key => 'parent_id'

  #validations
  validates :name, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :phone_no, presence: true, uniqueness: { case_sensitive: false }, length: { is: 10 }, numericality: { only_integer: true }
  validates :password, presence: true
  validate :validate_parent, on: [:update, :create]

  has_secure_password

  enum status: [:active, :inactive]
  enum user_type: [:Owner, :Broker, :Buyer]


  def self.is_parent(user)
    #Purpose: checks if user is a parent

    #Input: user object
    #Return value: boolean

    if User.find_by(parent_id: user.id)
      return true
    else
      return false
    end
  end


  def self.is_child(user)
    if user.parent.nil?
        return false
    else
        return true
    end
  end 


  #def self.get_parents


  def self.pass_vertical_check(user)
    #Purpose: checks if user has 2 vertical level of hierarchy
    #         Its purpose is to tell if user can support any child 
    #         If user is a grandchild then it returns false else true

    #Input: user object
    #Return value: boolean

    #user_parent_id = user.parent_id
    #@parent = User.find(user_parent_id)
    #if @parent.parent_id
    #  return false
    #else
    #  return true
    #end

    if is_grandchild(user)
        return false
    else
        return true
    end
  end


  def self.has_horizontal_hierarchy(user)
    #Purpose: checks if user has max children
    #         If so, then it cannot cannot be a eligible parent and cannot support a child
    #         It returns true if it can support children within max children limit, else false

    #Input: user object
    #Return value: boolean

    max_children_limit = 4
    #total_children_count = User.where(parent_id: user.id).count
    if user.children.count < max_children_limit
      return true
    else
      return false
    end
  end

  
  #def self.give_candidate_parents(current_user)
  #    #Purpose: finds eligible parents for current_user
#
#  #    #Input: 
#  #    #      current_user : for which candidate parents are to be found out
#
#  #    #Return value: array of User objects that are eligible parents
#
#  #    #Variables:
#  #    #          @all_users : All user objects in User
#  #    #          @candidate_parents : array of User objects that are eligible parents
#  #    #          user_parent : stores parent_id of user
#
#  #    @all_users = User.all
#  #    @candidate_parents = Array.new
#
#  #    @all_users.each do |user|
#  #      #do not include user itself in list of available parents
#  #      if user.id != current_user.id
#  #          user_parent = user.parent_id
#  #          #Case 1: when user is not a parent and not a child, then it is a candidate parent
#  #          #if user's parent is nil and user is not a parent itself
#  #          if !user_parent && !User.is_parent(user)
#  #              @candidate_parents.push(user)
#
#  #          #Case 2: when user has a parent but it is not a parent, then check vertical level hierarchy, to know if it is a grandchild
#  #          #else if user's parent is not nil and user is not a parent itself
#  #          elsif user_parent && !User.is_parent(user)
#  #            #if user is not a grandchild then it is a candidate parent
#  #            if User.pass_vertical_check(user)
#  #                @candidate_parents.push(user)
#  #            end
#
#  #          #Case 3: when user is a parent itself, then check if it can have any more children
#  #          else
#  #            if User.has_horizontal_hierarchy(user)
#  #                @candidate_parents.push(user)
#  #            end
#  #          end
#  #      end
#  #    end
#  #    return @candidate_parents       
  #end


  def self.is_grandchild(user)
    if not user.parent.nil?
        if user.parent.parent.nil?
            return false
        else
            return true
        end
    else
        return false
    end
  end


  def is_grandparent
    #byebug
    @children = self.children
    if @children.empty?
        return false
    else
        @children.each do |child|
          #byebug
              if not child.children.empty?
                  return true
              end
        end
        return false
    end
  end


#  def self.is_cycle(user, parent_to_be_validated)
#        children_of_parent_to_be_validated = parent_to_be_validated.children
#        if not children_of_parent_to_be_validated.empty?
#              children_of_parent_to_be_validated.each do |child|
#                    if child == user
#                        return true
#                    end
#              end
#        end
#        return false
#  end


  def self.calculate_depth(user, depth_count)
        if not user.parent.nil?
              return User.calculate_depth(user.parent, depth_count+1)
        else
              return depth_count
        end
  end


  def self.calculate_height(user, height_count)
        if not user.children.empty?
              #all_children = user.children
              child_max_height = 0
              user.children.each do |child|
                    child_height = User.calculate_height(child, 0)
                    if child_height > child_max_height
                          child_max_height = child_height
                    end
              end
              height_count = child_max_height + 1
        else
              return height_count
        end
  end


  def self.get_depth(user)
      return calculate_depth(user, 0)
  end


  def self.get_height(user)
      return calculate_height(user, 0)
  end


  def self.has_vertical_hierarchy(user, parent_to_be_validated)
        vertical_hierarchy_max = 2
        #parent_to_be_validated = User.find_by(id: self.parent_id)
        if User.get_height(user) + User.get_depth(parent_to_be_validated) < vertical_hierarchy_max
            return true
        else
            return false
            #errors.add(:parent_id, "This does not support vertical hierarchy.")
        end
  end


  def validate_parent
        if !self.parent_id.nil?
            if self.parent_id == self.id
                errors.add(:parent_id, "User ID and its Parent ID cannot be same")
            else
                
                parent_to_be_validated = User.find_by(id: self.parent_id)
                if parent_to_be_validated.nil?
                    errors.add(:parent_id, "No user exists with this ID")
                else
                    #if not User.pass_vertical_check(parent_to_be_validated)
                    if not User.has_vertical_hierarchy(self, parent_to_be_validated)
                        #errors.add(:parent_id, "This parent is already a grandchild.")
                        errors.add(:parent_id, "This does not support vertical hierarchy.")
                    #elsif
                    else
                        if not User.has_horizontal_hierarchy(parent_to_be_validated)
                            errors.add(:parent_id, "This parent already has 4 children.")
                        end
                    #elsif
                    #else
                    #    if User.is_parent(self) && User.is_child(parent_to_be_validated)
                    #        errors.add(:parent_id, "This does not support vertical hierarchy.")
                    #    end
                    #elsif User.is_cycle(self, parent_to_be_validated)
                    #    errors.add(:parent_id, "Cycle present.")
                    end
                end
            end
        end
  end

  #--------------------------------------------

  #Elasticsearch

  #whenever a new User is created, include it in index_document
  after_commit on: [:create] do
    __elasticsearch__.index_document
  end

  #whenever an User object is updated, then update document
  after_commit on: [:update] do
    __elasticsearch__.update_document
  end

 
  def self.search(query)
    #Purpose: searches query in following fields
	 __elasticsearch__.search(
	  {
	   query: {
	    multi_match: {
	     fields: [:name, :email, :phone_no],
       query: query,
       type: "phrase_prefix"
	    }
	   }
	  }
	 )
  end


  settings index: { number_of_shards: 1 } do
   	mappings dynamic: 'false' do
   		indexes :name
   		indexes :email
   		indexes :phone_no
 	  end
  end

end

#User.__elasticsearch__.create_index!
# User.import(force: true)  # for auto sync model with elastic search
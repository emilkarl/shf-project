class OrderedListEntryPolicy < ApplicationPolicy

  def new?
    user.admin?
  end


  def create?
    new?
  end


  def show?
    not_a_visitor?
  end


  def index?
    user.admin?
  end


  def update?
    user.admin?
  end


  def edit?
    update?
  end

  def destroy?
    update?
  end


  def max_list_position?
    show?
  end
end

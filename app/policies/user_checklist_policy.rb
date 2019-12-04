class UserChecklistPolicy < ApplicationPolicy

  def new?
    not_a_visitor?
  end


  def create?
    new?
  end


  def show?
    admin_or_owner?
  end


  def index?
    not_a_visitor?
  end


  def update?
    admin_or_owner?
  end


  def edit?
    update?
  end

  def destroy?
    update?
  end


end

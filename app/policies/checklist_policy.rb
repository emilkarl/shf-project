class ChecklistPolicy < ApplicationPolicy

  def new?
    user.admin?
  end


  def create?
    new?
  end


  def show?
    user.admin?
  end


  def index?
    user.admin?
  end


  def update?
    user.admin?
  end


  def edit?
    user.admin?
  end


  def destroy?
    user.admin?
  end

end

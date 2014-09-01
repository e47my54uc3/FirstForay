module Api
  module V1
    
    class GroupsController < ApiController
      before_filter :restrict_access 
      respond_to :json
      
      # POST /groups
      # POST /groups.json
      def create
        @group = Group.new()
        @group.name = params[:group_name] unless params[:user_id].blank?
        @group.reecher_id = params[:user_id] unless params[:user_id].blank?
        user = User.find_by_reecher_id(params[:user_id])
        assoc_user = User.find_by_reecher_id(params[:associated_user_id]) unless params[:associated_user_id].blank?
         
         if @group.save 
         check_existing_group_ass1 = Group::get_group_association user.id, @group.id
       
         ActiveRecord::Base.connection.execute("INSERT INTO `groups_users` (
  `group_id` ,`user_id`)VALUES (#{@group.id} , #{user.id});")  if check_existing_group_ass1.empty?
        
         check_existing_group_ass2 = Group::get_group_association assoc_user.id, @group.id
         
         ActiveRecord::Base.connection.execute("INSERT INTO `groups_users` (
  `group_id` ,`user_id`)VALUES (#{@group.id} , #{assoc_user.id});")  if check_existing_group_ass2.empty?
  
          # format.html { redirect_to @group, notice: 'Group was successfully created.' }
          #@group=@group.collect { |i| i  if i !='created_at' && i != "updated_at"}   
          msg = {:status => 200, :message => "success"}
          render :json => msg 
          else
          msg = {:status => 401, :message => "Group name has already been taken" }
          render :json => msg   
          end
          
      end
=begin    
      def associate_user_to_group
        user = User.find_by_reecher_id(params[:user_id])
        group = Group.find(params[:group_id]) if params[:group_id]
        assoc_user = User.find_by_reecher_id(params[:associated_user_id])
        add_to_group = params[:add_to_group]  
        
        
        if add_to_group
          check_existing_group_ass1 =  Group::get_group_association assoc_user.id,group.id
          if check_existing_group_ass1.empty?
          ActiveRecord::Base.connection.execute("INSERT INTO `groups_users` (
      `group_id` ,`user_id`) VALUES (#{group.id} , #{assoc_user.id});")   unless group.blank?
          end
          msg = {:status => 200, :message => "User Associated to the group #{group.name}" }   
        else  
          check_existing_group_ass1 =  Group::get_group_association assoc_user.id,group.id
          if !check_existing_group_ass1.empty?
         ActiveRecord::Base.connection.execute("DELETE FROM `groups_users` WHERE `groups_users`.`group_id` = #{group.id} AND `groups_users`.`user_id` = #{assoc_user.id}")  
          end
        msg = {:status => 200, :message => "User deleted from the group #{group.name}" }  
        end
        
        render :json => msg   
      end
=end

  def associate_user_to_group
      user = User.find_by_reecher_id(params[:user_id])
      groups_created_by_login_user = Group.select("id").where(:reecher_id => params[:user_id])
      
      ids=[]
      groups_created_by_login_user.each do |i|
        ids << i.id
      end
      groups = params[:group_id]
      associated_user = User.find_by_reecher_id(params[:associated_user_id])
      # add_to_group = params[:add_to_group]   
      ActiveRecord::Base.connection.execute("DELETE FROM `groups_users` WHERE `groups_users`.`group_id` IN (#{ids.join(',')}) AND user_id = #{associated_user.id}")
      if !groups.blank?
          groups.each do |g|
           group = Group.find(g) 
            ActiveRecord::Base.connection.execute("INSERT INTO `groups_users` (`group_id` ,`user_id`) VALUES (#{group.id} , #{associated_user.id})") 
          end
      msg = {:status => 200, :message => "User is Associated to the  groups",:group_ids=>groups} 
      else
      msg = {:status => 401, :message => "No group is selected." }  
      end
      
      render :json => msg   
end    
    
    
    
      
      def reecher_personal_groups
        user = User.find_by_reecher_id(params[:user_id])   unless params[:user_id].blank?
        groups = Group.select("id,name").where("reecher_id =?",user.reecher_id)
        msg = {:status => 200, :groups =>groups }            
         render :json => msg   
      end
    
      
    end
   
    
 end
end

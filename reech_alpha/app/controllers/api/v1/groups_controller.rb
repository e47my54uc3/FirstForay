module Api
  module V1
    
    class GroupsController < ApiController
      before_filter :restrict_access 
      respond_to :json
      # GET /groups
      # GET /groups.json
      def index
        @groups = Group.all
    
        respond_to do |format|
          format.html # index.html.erb
          format.json { render json: @groups }
        end
      end
    
      # GET /groups/1
      # GET /groups/1.json
      def show
        @group = Group.find(params[:id])
    
        respond_to do |format|
          format.html # show.html.erb
          format.json { render json: @group }
        end
      end
    
      # GET /groups/new
      # GET /groups/new.json
      def new
        @group = Group.new
    
        respond_to do |format|
          format.html # new.html.erb
          format.json { render json: @group }
        end
      end
    
      # GET /groups/1/edit
      def edit
        @group = Group.find(params[:id])
      end
    
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
          msg = {:status => 200, :message => "success" }
          render :json => msg 
          else
          msg = {:status => 401, :message => "Group name has already been taken" }
          render :json => msg   
          end
          
      end
    
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
    
      
      def reecher_personal_groups
        user = User.find_by_reecher_id(params[:user_id])   unless params[:user_id].blank?
        groups = Group.select("id,name").where("reecher_id =?",user.reecher_id)
         msg = {:status => 200, :groups =>groups }            
         render :json => msg   
      end
    
      # PUT /groups/1
      # PUT /groups/1.json
      def update
        @group = Group.find(params[:id])
    
        respond_to do |format|
          if @group.update_attributes(params[:group])
            format.html { redirect_to @group, notice: 'Group was successfully updated.' }
            format.json { head :no_content }
          else
            format.html { render action: "edit" }
            format.json { render json: @group.errors, status: :unprocessable_entity }
          end
        end
      end
    
      # DELETE /groups/1
      # DELETE /groups/1.json
      def destroy
        @group = Group.find(params[:id])
        @group.destroy
    
        respond_to do |format|
          format.html { redirect_to groups_url }
          format.json { head :no_content }
        end
      end
    end
   
    
 end
end

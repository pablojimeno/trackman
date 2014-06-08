class ConversationsController < ApplicationController


  def new
    @conversation = Mailbox::Conversation.new
  end

  # Create a brand new conversation
  def create
    render text: params
    return 
    
    recipient = User.find(conversation_params['recipient_id'])
    conversation = current_user.send_message(recipient, conversation_params["Body"], conversation_params["subject"]).conversation
    redirect_to conversation
  end

  # Reply to an existing conversation
  def reply
    current_user.reply_to_conversation(conversation, *message_params(:body, :subject))
    redirect_to conversation
  end

  def trash
    conversation.move_to_trash(current_user)
    redirect_to :conversations
  end

  def untrash
    conversation.untrash(current_user)
    redirect_to :conversations
  end

  def show
    @conversation = current_user.mailbox.conversations.find(params[:id])
  end

  private

  def conversation_params
    params.require(:conversation).permit(:body, :subject, :recipient_id)
  end

end
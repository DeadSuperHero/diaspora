class Services::Twitter < Service
  include Rails.application.routes.url_helpers

  MAX_CHARACTERS = 500
  SHORTENED_URL_LENGTH = 21
  LINK_PATTERN = %r{https?://\S+}

  def provider
    "mastodon"
  end

  def post post, url=''
    logger.debug "event=post_to_service type=mastodon sender_id=#{user_id} post=#{post.guid}"
    toot = attempt_post post
    post.toot_id = toot.id
    post.save
  end

  def profile_photo_url
    client.user(nickname).profile_image_url_https "original"
  end

  def post_opts(post)
    {toot_id: post.toot_id} if post.toot_id.present?
  end

  def delete_from_service(opts)
    logger.debug "event=delete_from_service type=mastodon sender_id=#{user_id} toot_id=#{opts[:toot_id]}"
    delete_from_mastodon(opts[:toot_id])
  end

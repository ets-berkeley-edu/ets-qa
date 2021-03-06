class SquiggyActivity

  attr_accessor :type,
                :points,
                :title

  def initialize(type, title, points)
    @type = type
    @title = title
    @points = points
  end

  ACTIVITIES = [
    VIEW_ASSET = new('asset_view', 'View an asset in the Asset Library', 0),
    GET_VIEW_ASSET = new('get_asset_view', 'Receive a view in the Asset Library', 0),

    LIKE = new('asset_like', 'Like an asset in the Asset Library', 1),
    GET_LIKE = new('get_asset_like', 'Receive a like in the Asset Library', 1),

    COMMENT = new('asset_comment', 'Comment on an asset in the Asset Library', 3),
    GET_COMMENT = new('get_asset_comment', 'Receive a comment in the Asset Library', 1),
    GET_COMMENT_REPLY = new('get_asset_comment_reply', 'Receive a reply on a comment in the Asset Library', 1),

    ADD_DISCUSSION_TOPIC = new('discussion_topic', 'Add a new topic in Discussions', 5),
    ADD_DISCUSSION_ENTRY = new('discussion_entry', 'Add an entry on a topic in Discussions', 3),
    GET_DISCUSSION_REPLY = new('get_discussion_entry_reply', 'Receive a reply on an entry in Discussions', 1),

    ADD_ASSET_TO_LIBRARY = new('asset_add', 'Add a new asset to the Asset Library', 5),

    SUBMIT_ASSIGNMENT = new('assignment_submit', 'Submit a new assignment in Assignments', 20)
  ]

end

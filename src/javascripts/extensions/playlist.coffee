$ = require('jquery')
sightglass = require('sightglass')
rivets = require('rivets')

class PlaylistItem
  constructor: (context, callback) ->
    @context = context
    @callback = callback

  render: =>
    @elem = $(@defaultHtml)
    rivets.bind(@elem, @context)

    @elem.data('item', @context)
    @elem.on('click', 'img, span', @context, @callback)

    return @elem

  defaultHtml:
    """
    <li>
      <img rv-src="image" rv-if="image" />
      <span>{ title }</span>
      <a rv-if="href" rv-href="href" target="_blank"><i class="fa fa-external-link"></i></a>
    </li>
    """

class Playlist
  @extension:
    name: 'Playlist'
    type: 'panel'

  constructor: (@app) ->
    @feed = @app.podcast.feed
    return unless @feed

    @feed.promise.done =>
      @renderPanel()
      @renderButton()

      @app.renderPanel(this)

  click: (event) =>
    item = event.data
    @app.episode.title = item.title
    @app.episode.subtitle = item.subtitle
    @app.episode.description = item.description
    @app.episode.playlist.mp3 = item.enclosure

  renderButton: =>
    @button = $(@buttonHtml)
    @button.on 'click', =>
      @app.togglePanel(@panel)

  renderPanel: =>
    @panel = $(@panelHtml)
    @panel.hide()

    list = @panel.find('ul')
    $(@feed.items).each((index, feedItem) =>
      item = $(feedItem)
      item = {
        title: item.find('title').html(),
        subtitle: item.find('subtitle').html(),
        href: item.find('link').html(),
        enclosure: item.find('enclosure').attr('url'),
        description: item.find('description').html()
      }
      playlistItem = new PlaylistItem(item, @click).render()
      list.append(playlistItem)
    )

  buttonHtml:
    """
    <i class="fa fa-bookmark playlist-button" title="Show playlist"></i>
    """

  panelHtml:
    """
    <div class="playlist"><ul></ul></div>
    """

module.exports = Playlist

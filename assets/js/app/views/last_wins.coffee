class window.App.LastWinsView extends App.MasterView

  el: null

  tpl: null

  player: null

  initialize: ({@tpl, @player})->
    @tpl = "last-wins-tpl"

  render: ()->
    @collection.fetch
      success: ()=>
        $lastWinsList = @$("#last-wins:first")
        slug = if @player.get("type") is "premium" then "?player=#{@player.get('slug')}" else ""
        $lastWinsList.html @template({lastWins: @collection, slug: slug})
        $lastWins = $lastWinsList.find(".last-win")
        totalLastWins = $lastWins.length
        $lastWinsList.width $lastWins.first().outerWidth() * totalLastWins
        $lastWinsList.fadeIn()
        @$el.scrollLeft $lastWinsList.width()
        setInterval @scrollWins, 7000

  scrollWins: ()=>
    $lastWinsList = @$("#last-wins:first")
    if @$el.scrollLeft() is 0
      @$el.animate
        scrollLeft: $lastWinsList.width()
    else
      $lastWins = $lastWinsList.find(".last-win")
      scrollOffset = $lastWins.first().outerWidth()
      @$el.animate
          scrollLeft: "-=#{scrollOffset}"
        ,
        800
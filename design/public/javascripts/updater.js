if (typeof RT == "undefined") RT = {};

RT.delay = 10;

RT.Updater = Class.create({
  initialize: function() {
    this.form = $('vote').down('form');
    this.progressBar = $('progress').down('div');
    this.results = $('results');
    this.request = false;
    new Ajax.Request('results', {
      onSuccess: function(response) {
        this.render(response.responseText);
        this.resetTimer();
        new PeriodicalExecuter(this.updateTimer.bind(this), 1);
      }.bind(this),
    });
  },
  
  render: function(json) {
    out = '';  // TODO Find out what's the fastest way to build the html
    json.evalJSON().minutes.each(function(minute) {
      var timestamp = new Date(parseInt(minute.timestamp, 10));
      var minutes = timestamp.getMinutes();
      if (minutes % 15 != 0) {
        timestamp = false;
      }
      out += '<div class="m' + (timestamp ? ' s' : '') + (minutes === 0 ? ' h' : '') + '" id="m_' + minute.id + '">\n';
      minute.stars.each(function(star, index) {
        var width = star * 100;
        var color = 55 + Math.round(star * 200);
        color = color + ',' + color + ',' + color;
        out += '<div><div style="width: ' + width + '%; background-color: rgb(' + color + ')"></div>';
        if (index == minute.user) {
          out += '<span></span>';
        }
        out += '</div>\n';
      });
      if (timestamp) {
        out += '<span class="t" title="' + timestamp.toLocaleString() + '">' + timestamp.getHours() + ':' + (minutes < 10 ? '0' : '') + minutes + '</span>'
      }
      out += '</div>\n';
    });
    // console.log(out);
    this.results.insert({top: out});
  },
  
  resetTimer: function() {
    this.progressBar.removeClassName('smooth').setStyle({width: '100%'});
    setTimeout(function() {
      this.progressBar.addClassName('smooth');
      this.then = new Date().getTime();
    }.bind(this), 50);
  },
  
  mostRecentMinuteId: function() {
    return this.results.down('div.m').id.substring(2);
  },
  
  updateTimer: function(executer) {
    var left = (RT.delay + (this.then - new Date().getTime()) / 1000);
    if (left > 0) {
      var width = left / RT.delay * 100;
      if (width < 0) {
        width = 0;
      }
      this.progressBar.setStyle({width: width + '%'});
    } else if (!this.request) {
      this.progressBar.setStyle({width: '0'});
      $(document.body).addClassName('loading');
      var id = this.mostRecentMinuteId();
      var url = this.form.getAttribute('action') + '?id=' + id;
      url = url.gsub('?id=', '-');  // TODO For development
      this.request = new Ajax.Request(url, {
        parameters: this.form.serialize(true),
        onSuccess: function(response) {
          if (id == this.mostRecentMinuteId()) {
            this.render(response.responseText);
          }
        }.bind(this),
        onComplete: function(response) {
          this.resetTimer();
          this.request = false;
          $(document.body).removeClassName('loading');
        }.bind(this)
      });
    }
  },
});

new RT.Updater();
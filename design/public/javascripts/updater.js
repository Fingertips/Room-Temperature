if (typeof RT == "undefined") RT = {};

RT.delay = 60;

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
    var data = json.evalJSON();
    this.latest = data.minutes.first().timestamp;
    out = '';  // TODO Find out what's the fastest way to build the html
    data.minutes.each(function(minute) {
      var timestamp = new Date(parseInt(minute.timestamp, 10) * 1000);
      var minutes = timestamp.getMinutes();
      out += '<div class="minute' + (minutes % 15 == 0 ? ' separator' : '') + (minutes === 0 ? ' hour' : '') + '">\n';
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
      if (minutes % 15 == 0) {
        out += '<span class="timestamp" title="' + timestamp.toLocaleString() + '">' + timestamp.getHours() + ':' + (minutes < 10 ? '0' : '') + minutes + '</span>'
      }
      out += '</div>\n';
    });
    if (data.intent == 'replace') {
      this.results.update(out);
    } else {
      this.results.insert({top: out});
    }
  },
  
  resetTimer: function() {
    this.progressBar.removeClassName('smooth').setStyle({width: '100%'});
    setTimeout(function() {
      this.progressBar.addClassName('smooth');
      this.then = new Date().getTime();
    }.bind(this), 50);
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
      var url = this.form.getAttribute('action') + '?since=' + this.latest;
      url = url.gsub('?since=', '-');  // TODO For development
      var latest = this.latest;
      this.request = new Ajax.Request(url, {
        parameters: this.form.serialize(true),
        onSuccess: function(response) {
          if (latest == this.latest) {
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
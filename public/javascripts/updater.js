if (typeof RT == "undefined") RT = {};

RT.delay = 60;

RT.Updater = Class.create({
  initialize: function() {
    this.form = $('vote').down('form');
    this.progressBar = $('progress').down('div');
    this.results = $('results');
    this.request = false;
    this.stars = new RT.Stars(this.form);
    var standingUrl = this.form.getAttribute('action').split('/').slice(0, -1).concat('standing').join('/');
    new Ajax.Request(standingUrl, {
      method: 'GET',
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
      var timestamp_minutes = timestamp.getMinutes();
      var yours = data.yours && data.yours[minute.timestamp];
      out += '<div class="minute' + (timestamp_minutes % 15 == 0 ? ' separator' : '') + (timestamp_minutes === 0 ? ' hour' : '') + '">\n';
      minute.stars.each(function(star, index) {
        var width = star * 100;
        var color = 55 + Math.round(star * 200);
        color = color + ',' + color + ',' + color;
        out += '<div><div style="width: ' + width + '%; background-color: rgb(' + color + ')"></div>';
        if (yours == index+1) {
          out += '<span></span>';
        }
        out += '</div>\n';
      });
      if (timestamp_minutes % 15 == 0) {
        out += '<span class="timestamp" title="' + timestamp.toLocaleString() + '">' + timestamp.getHours() + ':' + (timestamp_minutes < 10 ? '0' : '') + timestamp_minutes + '</span>'
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
      
      var latest = this.latest;
      this.request = new Ajax.Request(url, {
        parameters: this.form.serialize(true),
        onSuccess: function(response) {
          if (latest == this.latest) {
            this.form.reset();
            this.stars.updateChecked();
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
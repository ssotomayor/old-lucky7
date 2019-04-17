(function($){
	if(typeof $.sound === "undefined" || !$.sound){
		var sound={
			support: false,
			count: 0,
			load:function(url, options){
        options = $.extend({
          loop: false
        }, options, true);
				return new function(){
					var id='sfx' + $.sound.count;
					this.surl=url;
					this.a = $.sound.createAudioElement[$.sound.support](id,url);
					this.play = $.sound.playAudioElement[$.sound.support];
          this.pause = $.sound.pauseAudioElement[$.sound.support];
          this.a.loop = options.loop;
					$.sound.count++;
				}
			},
			createAudioElement:{
				mp3:function(id,url){ return $.sound.createHTML5Audio(url); },
				ogg:function(id,url){ return $.sound.createHTML5Audio(url); },
				m4a:function(id,url){ return $.sound.createHTML5Audio(url); },
				bgsound:function(id,url){
					return $('<bgsound id="'+id+'" src="#" loop="1">').appendTo('body').get(0);
				},
				qtime:function(id,url){
					return $('<object id="'+id+'" width="0" height="0" type="audio/mpeg" autostart="false" enablejavascript="true" data="'+url+'.mp3"/>').appendTo('body').get(0);
				},
				wmp:function(id,url){
					return $('<embed id="'+id+'" type="application/x-mplayer2" height="0" width="0" autostart="0" src="'+url+'.mp3"></embed>').appendTo('body').get(0);
				},
				rp:function(id,url){
					return $('<embed type="audio/x-pn-realaudio-plugin" style="height:0" id="'+id+'" src="'+url+'.mp3" loop="false" autostart="false" hidden="true"/>').appendTo('body').get(0);
				}
			},
			createHTML5Audio:function(url){
				var a = new Audio();
				a.src = url+"."+$.sound.support;
				return a;
			},
			playAudioElement:{
				mp3:function(){ $.sound.playHTML5Audio.apply(this); },
				ogg:function(){ $.sound.playHTML5Audio.apply(this); },
				m4a:function(){ $.sound.playHTML5Audio.apply(this); },
				bgsound:function(){ this.a.src = this.surl + '.mp3'; },
				qtime:function(){ $.sound.playPluginAudio.apply(this); },
				wmp:function(){ $.sound.playPluginAudio.apply(this); },
				rp:function(){ $.sound.playPluginAudio.apply(this); }
			},
      pauseAudioElement:{
        mp3:function(){ $.sound.pauseHTML5Audio.apply(this); },
        ogg:function(){ $.sound.pauseHTML5Audio.apply(this); },
        m4a:function(){ $.sound.pauseHTML5Audio.apply(this); },
        bgsound:function(){ this.a.src = this.surl + '.mp3'; },
        qtime:function(){ $.sound.pausePluginAudio.apply(this); },
        wmp:function(){ $.sound.pausePluginAudio.apply(this); },
        rp:function(){ $.sound.pausePluginAudio.apply(this); }
      },
			playHTML5Audio:function(){
				if(this.a.currentTime){
					this.a.currentTime = 0;	
					if(this.a.currentTime != 0) this.a.src = this.surl+"."+$.sound.support;
				}
				this.a.play();
			},
      pauseHTML5Audio:function(){
        this.a.pause();
      },
			playPluginAudio:function(){
				$.sound.support == 'rp' ? this.a.DoPlay() : this.a.Play();
			},
      pausePluginAudio:function(){
        $.sound.support == 'rp' ? this.a.DoPause() : this.a.Pause();
      }
		};
		$.extend({sound:sound});
	}
	
	var pluginList={
		qtime:{activex:"QuickTime.QuickTime",plugin:/quicktime/gim},
		wmp:{activex:"WMPlayer.OCX",plugin:/(windows\smedia)|(Microsoft)/gim},
		rp:{activex:"RealPlayer",plugin:/realplayer/gim}
	};
	
	var isSupported = function(p){
		var rv = false;
		if(window.ActiveXObject){
			try{
				new ActiveXObject(pluginList[p].activex);
				rv = true;
			}catch(e){
			}
		}else{
			$.each(navigator.plugins,function(){
				if(this.name.match(pluginList[p].plugin)){
					rv = true;
					return false;
				}
			});
		}
		return rv;
	};
	
	if("Audio" in window) {
		var a = new Audio();
		if(!!(a.canPlayType && a.canPlayType('audio/ogg; codecs="vorbis"').replace(/no/, '')))
			$.sound.support = "ogg";
		else if(!!(a.canPlayType && a.canPlayType('audio/mpeg;').replace(/no/, '')))
			$.sound.support = "mp3";
		else if(!!(a.canPlayType && a.canPlayType('audio/mp4; codecs="mp4a.40.2"').replace(/no/, '')))
			$.sound.support = "m4a";
		else
			$.sound.support = "mp3";
	} else {
		if(navigator.userAgent.indexOf('MSIE') >= 0){
			$.sound.support = 'bgsound';
		} else {
			$.each(pluginList,function(i,n){
				if(isSupported(i)) {
					$.sound.support = i;
					return false;
				}
			});				
		}			
	}
})(jQuery);
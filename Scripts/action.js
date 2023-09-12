 //action standard
 (function () {
    var $layer1 = $('#layer1'),
        $layer1_1 = $('#layer1 .st10'),
        $layer1_2 = $('#layer1 .st11'),
        $layer1_3 = $('#layer1 .st12'),
        $layer1_4 = $('#layer1 .st13'),
        $layer2 = $('#layer2'),
        $layer3 = $('#layer3'),
        $layer4 = $('.st0,.st1,.st2,.st3,.st4,.st5,.st6,.st7'),
        $action_box = $('.logo-action'),
        $Body = $('body'),
        act = new TimelineMax({
             repeat: 0,
             delay: 1,
             yoyo: !1,
             paused: !1
         });
     act.timeScale(1.3);
     TweenMax.set($layer1, {
        transformOrigin: "50% 50%",
        alpha: 0,
        scale: 15,
        rotation: -360,
        skew: -100
    });
    TweenMax.set([$layer1_1], {
        transformOrigin: "50% 50%",
        rotation: -360,
        yPercent: 250,
        alpha: 0
    });
    TweenMax.set([$layer1_2], {
        transformOrigin: "50% 50%",
        rotation: -360,
        yPercent: -250,
        alpha: 0
    });
    TweenMax.set($layer2, {
        transformOrigin: "50% 50%",
        alpha: 0,
        rotation: 90,
        scale: 1.2
    });
    TweenMax.set($layer3, {
        transformOrigin: "50% 50%",
        alpha: 0,
        scale: 0
    });
    TweenMax.set($layer4, {
        transformOrigin: "50% 50%",
        alpha: 1,
        scale: 1
    });
    if(document.cookie == 'name=ASG'){
        $Body.removeClass('body-hidden');
        $action_box.css({
            "display": "none"
        });
    }else{
         act.to($layer3, .5, {
                 alpha: 0,
                 scale: 1,
                 ease: Power3.easeOut
             })
             .to($layer3, 4, {
                alpha: 1,
                ease: Power2.easeOut
            })
            .to($layer1, 6, {
                scale: 1,
                alpha: 1,
                delay: 2,
                rotation: 0,
                ease: Power1.easeOut
            },'-=4.5')
            .to([$layer1_1,$layer1_2,$layer1_3,$layer1_4], 6, {
                rotation: 0,
                alpha: 1,
                yPercent: 0,
                ease: Power3.easeOut
            },"-=4.5")
            .to($layer2, 9, {
                alpha: 1,
                rotation: 0,
                scale: 1,
                ease: Power1.easeOut
            },"-=7")
            .staggerFrom($layer4, 1.5, {
    			alpha: 0,
    			scaleX: 0,
    			ease: Power3.easeOut
            },0.2, "-=4.5")
            .to($action_box, 3, {
                alpha: 0,
                ease: Power4.easeOut
            })
            .add(function() {
                $Body.removeClass('body-hidden');
                $action_box.css({
                  "display": "none"
                });
              }, '-=1');
    }
    document.cookie = "name=ASG";
 })();
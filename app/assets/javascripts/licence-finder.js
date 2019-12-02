//= require govuk_publishing_components/all_components

/*globals $ */
/*jslint
 white: true,
 sloppy: true,
 browser: true,
 vars: true,
 plusplus: true
*/
$(function() {

    // $('el:bottom-offscreen') will return true if the element's
    // bottom box border is off the screen
    $.expr.filters['bottom-offscreen'] = function(el) {
        var $window = $(window),
            $el = $(el),
            bottomOfWindow = ($window.scrollTop() + $window.height()),
            elBottom = $el.offset().top + $el.height();
        return (elBottom > bottomOfWindow);
    };

    var pageName = window.location.pathname.split("/").pop(),
        selectedItems,
        browseUrl;

    selectedItems = (function () {
        var items = [];

        return {
            add: function(id) {
                items.push(id + '');
            },
            remove: function(id) {
                var idx = items.length,
                    found = false,
                    tmpArr = [];

                while (idx--) {
                    if (items[idx] !== id) {
                        tmpArr.push(items[idx]);
                    } else {
                        found = true;
                    }
                }

                items = tmpArr;

                return found;
            },
            contains: function(id) {
                var idx = $.inArray(id, items);

                if (idx === -1) {
                    return false
                }

                return true;
            },
            get: function() {
                return items.slice(0);
            }
        };
    }());

    function extractIds() {
        return $.makeArray(
            $(".picked-items li[data-public-id]").map(function(i, li) {
                return $(li).data("public-id");
            })
        );
    }

    function extractParams() {
        var params = {};

        // check there are any GET params at all
        $(window.location.search.substr(1).split('&')).each(function(i, pair)  {
            if (pair !== "") {
                pair = pair.split('=');
                params[pair[0]] = pair[1];
            }
        });

        return params;
    }

    function createAddRemoveUrl(id) {
        var ids = selectedItems.get(),
            params = extractParams(),
            index = $.inArray(id, ids);
        if (index === -1) {
            ids.push(id);
        } else {
            ids.splice(index, 1);
        }

        if (ids.length > 0) {
            params[pageName] = ids.join("_");
        }

        return window.location.pathname + "?" + $.param(params);
    }

    function createNextUrl() {
        var ids = selectedItems.get(),
            params = extractParams(),
            next, query;
        if (pageName === "sectors") {
            next = "/activities";
            query = "sectors=" + ids.join("_");
        } else {
            next = "/location";
            query = "sectors=" + params.sectors + "&activities=" + ids.join("_");
        }

        return window.location.pathname.replace("/"+pageName, next) + "?" + query;
    }

    // Move a list item from one list to another.
    function swapper(event) {
        event.preventDefault();
        var targetClass = '.picked-items',
            oldli,
            newli,
            source = $(event.delegateTarget), // container for list that item is coming from
            target = $(targetClass), // container for list that item is going to
            targetList = $("ul", target),
            itemId,
            prefix = (pageName === 'activities') ? 'activity' : 'sector';

        if (event.data.action === 'add') {
            oldli = $(this).parent(); // the list item that is being moved
            itemId = oldli.data("public-id");
            newli = $('<li data-public-id="' + itemId + '"></li>'); // the target list item

            // move the item
            newli.append(oldli.find("span:first").clone().attr('id',  prefix + '-' + itemId + '-selected')).append(" ")
                 .append($('<a href="" class="govuk-link">' + event.data.linkText + '</a>'));
            targetList.append(newli);

            $('li', targetList).each(function() {
                var $link = $('a', this),
                    $label = $('span', this),
                    listItemId = $(this).data('public-id');

                $link.attr('href', createAddRemoveUrl(listItemId))
                    .attr('aria-labelledby', prefix + '-' + listItemId + '-selected')
                    .addClass('remove');
                if ($(this).is('.search-picker li') && !$link.hasClass('add')) {
                    $link.removeClass('remove');
                    $link.addClass('add');
                }
            });

            // update the activity/sector
            oldli
                .addClass('selected')
                .find('a')
                .removeClass('add')
                .addClass('remove')
                .text(event.data.linkText);

            // sort the list of selected activities/sectors
            var newlis = $('>li', targetList);
            newlis.remove();
            newlis = $.makeArray(newlis);
            newlis.sort(function(a, b) {
                return $("span", a).text().localeCompare($("span", b).text());
            });
            targetList.append(newlis);

            selectedItems.add(itemId);
        } else {

            itemId = $(this).attr('aria-labelledby').replace('-selected', '');

            $('#' + itemId + '-selected').parent('li').remove();
            $('#' + itemId).parent('li')
                .removeClass('selected')
                .find('a')
                .removeClass('remove')
                .addClass('add')
                .text(event.data.linkText);

            selectedItems.remove(itemId.replace(prefix + '-', ''));
        }

        // update links and forms to reflect the move
        if (event.data.action === "add") {
            $(".hint", target).removeClass("hint").addClass("hidden");
            $(".button-container", target).removeClass("js-hidden")
        } else if (target.find("li").length === 0) {
            $(".hidden", target).removeClass("hidden").addClass("hint");
            $(".button-container", target).addClass("js-hidden")
        }
        $(".button-container .govuk-button").attr("href", createNextUrl());
        if (pageName === "sectors") {
            $("#search-again-button").attr(
                "href", window.location.pathname + "?sectors=" + extractIds().join("_"));
            $("#hidden-sectors").attr("value", extractIds().join("_"));
        }
    }

    // event handler to add a list item to the picked list.
    $(".search-container, .browse-container").on("click", "li[data-public-id] a.add", {
        action: "add",
        linkText: "Remove"
    }, swapper);

    // event handler to remove a list item from the picked list.
    $(".picked-items, .browse-container, .search-container").on("click", "li[data-public-id] a.remove", {
        action: "remove",
        linkText: "Add"
    }, swapper);

    // ajax sector navigation
    function collapseOpenList(el) {
        var publicId = el.data('public-id'),
            url = el.attr('href');
        if (el.is('li.open>a')) {
            url = el.data('old-url');
            el.siblings('ul').remove();
            var a = $('<a class="govuk-link" href="'+url+'" data-public-id="'+publicId+'">'+el.text()+'</a>');
            el.replaceWith(a);

            a.parent().removeClass('open');
        }
    }
    function cleanOpenLists(el) {
        // removes all non-related "open" lists
        var parentLists = el.parentsUntil('#sector-navigation', 'ul');
        if (parentLists.length > 0) {
            $('#sector-navigation li.open>a').each(function() {
                var parents = $(this).closest('ul');
                if (parents.length > 0) {
                    if (!$.inArray(parents[0], parentLists)) {
                        collapseOpenList($(this));
                    }
                }
            });
        }
        else {
            $('#sector-navigation li.open>a').each(function() {
                collapseOpenList($(this));
            });
        }
    }

    function initSectorBrowsing() {
        var checkExisting = function () {
          var $pickedItems = $('.picked-items ul li');
          if (selectedItems.get().length !== $pickedItems.length) {
            $pickedItems.each(function (idx) {
              var id = $(this).data('public-id');

              selectedItems.add(id);
            });
          }
        };

        checkExisting();

        $('#sector-navigation').on('click', 'li:not(.open)>a:not(.add), li:not(.open)>a:not(.remove)', function(e) {
            e.preventDefault();
            var $a = $(this),
                url = $a.attr('href') + '.json',
                name = $a.text(),
                publicId = $a.data('public-id'),
                isActive,
                i, l;

            $.ajax(url, {
                dataType: 'json',
                cache: false,
                success: function(data) {
                    if (typeof data.sectors !== "undefined") {
                        cleanOpenLists($a);
                        checkExisting();

                        var children = data.sectors,
                            name = $a.text(),
                            $openA = $('<a class="govuk-link" data-public-id="' + publicId + '" data-old-url="' + $a.attr('href')+'">' + name + '</a>'),
                            ul = $('<ul />');

                        for (i=0, l=children.length; i<l; i++) {
                            var leaf = children[i],
                                elString,
                                isActive = selectedItems.contains(leaf['public-id']),
                                itemClass = (isActive) ? ' class="selected"' : '',
                                linkClass = (isActive) ? 'remove' : 'add',
                                linkText = (isActive) ? 'Remove' : 'Add';

                            if (typeof leaf.url !== 'undefined') {
                                elString = '<a class="govuk-link" data-public-id="' + leaf['public-id'] + '" href="' + leaf.url + '">' + leaf.name + '</a>';
                            }
                            else {
                                elString = '<span class="sector-name" id="sector-'+leaf['public-id']+'">' +
                                    leaf.name +
                                    '</span> <a aria-labelledby="sector-'+leaf['public-id']+'" href="' + createAddRemoveUrl(leaf['public-id']) + '" rel="nofollow" class="govuk-link ' + linkClass  + '">' +
                                    linkText +
                                    '</a>';
                            }

                            ul.append('<li' + itemClass  + ' data-public-id="' + leaf['public-id'] + '">' + elString + '</li>');
                        }

                        // insert correct parent URL on open links
                        var $parentLink = $a.closest('ul'),
                            parentUrl = browseUrl;

                        if ($parentLink.first()) {
                            var parentLink = $parentLink.first().siblings('a').first();
                            if (parentLink.length > 0) {
                                parentUrl = $(parentLink[0]).attr('data-old-url');
                            }
                        }

                        $a.parent().addClass('open');
                        $openA.attr('href', parentUrl);

                        $a.replaceWith($openA);
                        ul.insertAfter($openA);

                        $openA.on('click', function(e) {
                            e.preventDefault();
                            collapseOpenList($(this));
                        });

                        // scroll to top of page, taking top bar and a
                        // few extra pixels into account
                        if ($openA.siblings('ul:first').is(':bottom-offscreen')) {
                            $('html, body').animate({
                                scrollTop: $openA.offset().top - $('#global-header').height() - 15
                            }, 500);
                        }
                    }
                }
            });
        });
    }

    initSectorBrowsing();

    // dynamic sector browsing on sector homepage
    $('a#browse-sectors').on('click', function(e) {
        e.preventDefault();

        var $a = $(this),
            url = $a.attr('href') + '.json';

        browseUrl = $a.attr('href');

        $.ajax(url, {
            dataType: 'json',
            cache: false,
            success: function(data) {
                if (typeof data.sectors !== 'undefined') {
                    var heading = $('<h3>All activities and businesses:</h3>'),
                        sectorList = $('<ul id="sector-navigation"></ul>'),
                        i, l;
                    for (i=0, l=data.sectors.length; i<l; i++) {
                        var li = $('<li />'),
                            a = $('<a />'),
                            leaf = data.sectors[i];
                        li.append(a);
                        a.attr('href', leaf.url).attr('data-public-id', leaf['public-id']).text(leaf.name);
                        sectorList.append(li);
                    }
                    $a.parent().replaceWith(sectorList);
                    heading.insertBefore(sectorList);
                    initSectorBrowsing();
                }
            }
        });
    });
});

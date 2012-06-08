/*globals $ */
/*jslint
 white: true,
 sloppy: true,
 browser: true,
 vars: true,
 plusplus: true
*/
$(function() {
    var pageName = window.location.pathname.split("/").pop();

    function extractIds() {
        return $.makeArray(
            $(".picked-items li[data-public-id]").map(function(i, li) { return $(li).data("public-id"); })
        );
    }

    function extractParams() {
        var params = {};

        // check there are any GET params at all
        if (window.location.search.indexOf('&') !== -1) {
            $(window.location.search.substr(1).split('&')).each(function(i, pair)  {
                if (pair !== "") {
                    pair = pair.split('=');
                    params[pair[0]] = pair[1];
                }
            });
        }

        return params;
    }

    function createAddRemoveUrl(id) {
        var ids = extractIds(),
            params = extractParams();
        if (ids.indexOf(id) === -1) {
            ids.push(id);
        } else {
            ids.splice(ids.indexOf(id), 1);
        }

        if (ids.length > 0) {
            params[pageName] = ids.join("_");
        }

        return window.location.pathname + "?" + $.param(params);
    }

    function createNextUrl() {
        var ids = extractIds(),
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
        var oldli = $(this).parent(), // the list item that is being moved
            newli = $('<li data-public-id="' + oldli.data("public-id") + '"></li>'), // the target list item
            source = $(event.delegateTarget), // container for list that item is coming from
            target = $(event.data.target), // container for list that item is going to
            targetList = $("ul", target);

        // move the item
        newli.append(oldli.find("span:first")).append(" ")
             .append($('<a href="">' + event.data.linkText + '</a>'));
        targetList.append(newli);
        $('li', targetList).each(function() {
            $('a', this).attr('href', createAddRemoveUrl($(this).data('public-id')));
        });
        oldli.remove();

        // sort the target list if required
        if (event.data.sortTarget) {
            var newlis = $('>li', targetList);
            newlis.remove();
            newlis = $.makeArray(newlis);
            newlis.sort(function(a, b) {
                return $("span", a).text().localeCompare($("span", b).text());
            });
            targetList.append(newlis);
        }

        // update links and forms to reflect the move
        if (event.data.target === ".picked-items") {
            $(".hint", target).removeClass("hint").addClass("hidden");
            if ($("#next-step").length === 0) {
                target.append('<a href="" class="button medium" id="next-step">Next step</a>');
            }
        } else if (source.find("li").length === 0) {
            $(".hidden", source).removeClass("hidden").addClass("hint");
            $("#next-step").remove();
        }
        $("#next-step").attr("href", createNextUrl());
        if (pageName === "sectors") {
            $("#search-again-button").attr("href", window.location.pathname + "?sectors=" + extractIds().join("_"));
            $("#hidden-sectors").attr("value", extractIds().join("_"));
        }
    }

    // event handler to add a list item to the picked list.
    $(".search-container").on("click", "li[data-public-id] a.add", {
        linkText: "Remove",
        target: ".picked-items",
        sortTarget: true
    }, swapper);
    // event handler to remove a list item from the picked list.
    $(".picked-items").on("click", "li[data-public-id] a", {
        linkText: "Add",
        target: ".search-picker",
        sortTarget: (pageName === "activities")
    }, swapper);

    // ajax sector navigation
    function collapseOpenList(el) {
        var publicId = el.data('public-id'),
            url = el.attr('href');
        if (el.is('strong')) {
            url = el.data('old-url');
            el.siblings('ul').remove();
            var a = $('<a href="'+url+'" data-public-id="'+publicId+'">'+el.text()+'</a>');
            el.replaceWith(a);
        }
    }
    function cleanOpenLists(el) {
        // removes all non-related "open" lists
        var parentLists = el.parentsUntil('#sector-navigation', 'ul');
        if (parentLists.length > 0) {
            $('#sector-navigation strong').each(function() {
                var parents = $(this).closest('ul');
                if (parents.length > 0) {
                    if (!$.inArray(parents[0], parentLists)) {
                        collapseOpenList($(this));
                    }
                }
            });
        }
        else {
            $('#sector-navigation strong').each(function() {
                collapseOpenList($(this));
            });
        }
    }

    function initSectorBrowsing() {
        $('#sector-navigation').on('click', 'li>a:not(.add)', function(e) {
            e.preventDefault();
            var $a = $(this),
                url = $a.attr('href') + '.json',
                name = $a.text(),
                publicId = $a.data('public-id'),
                i, l;
            $.ajax(url, {
                dataType: 'json',
                cache: false,
                success: function(data) {
                    if (typeof data.sectors !== "undefined") {
                        cleanOpenLists($a);

                        var children = data.sectors,
                            name = $a.text(),
                            $strong = $('<strong data-public-id="' + publicId + '" data-old-url="'+$a.attr('href')+'">' + name + '</strong>'),
                            ul = $('<ul />');
                        for (i=0, l=children.length; i<l; i++) {
                            var leaf = children[i],
                                elString;

                            if (typeof leaf.url !== 'undefined') {
                                elString = '<a data-public-id="'+leaf['public-id']+'" href="'+leaf.url+'">'+leaf.name+'</a>';
                            }
                            else {
                                elString = '<span class="sector-name">' + leaf.name + '</span> <a href="'+createAddRemoveUrl(leaf['public-id'])+'" class="add">Add</a>';
                            }

                            ul.append('<li data-public-id="'+leaf['public-id']+'">' + elString + '</li>');
                        }

                        $a.replaceWith($strong);
                        ul.insertAfter($strong);
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

        $.ajax(url, {
            dataType: 'json',
            cache: false,
            success: function(data) {
                if (typeof data.sectors !== 'undefined') {
                    var heading = $('<h3>All activities and businesses</h3>'),
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
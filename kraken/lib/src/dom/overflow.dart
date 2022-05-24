/*
 * Copyright (C) 2019-present The Kraken authors. All rights reserved.
 */
import 'package:flutter/animation.dart';
import 'package:flutter/rendering.dart';
import 'package:kraken/css.dart';
import 'package:kraken/dom.dart';
import 'package:kraken/gesture.dart';
import 'package:kraken/rendering.dart';

// Styles which need to copy from outer scrolling box to inner scrolling content box.
List<String> _scrollingContentBoxCopyStyles = [
  DISPLAY,
  LINE_HEIGHT,
  TEXT_ALIGN,
  WHITE_SPACE,
  FLEX_DIRECTION,
  FLEX_WRAP,
  ALIGN_CONTENT,
  ALIGN_ITEMS,
  ALIGN_SELF,
  JUSTIFY_CONTENT,
  COLOR,
  TEXT_DECORATION_LINE,
  TEXT_DECORATION_COLOR,
  TEXT_DECORATION_STYLE,
  FONT_WEIGHT,
  FONT_STYLE,
  FONT_FAMILY,
  FONT_SIZE,
  LETTER_SPACING,
  WORD_SPACING,
  TEXT_SHADOW,
  TEXT_OVERFLOW,
  LINE_CLAMP,
];

mixin ElementOverflowMixin on ElementBase {
  // The duration time for element scrolling to a significant place.
  static const SCROLL_DURATION = Duration(milliseconds: 250);

  KrakenScrollable? _scrollableX;
  KrakenScrollable? _scrollableY;

  ScrollListener? scrollListener;
  void Function(PointerEvent)? scrollablePointerListener;

  ViewportOffset? get scrollOffsetX => _scrollOffsetX;
  ViewportOffset? _scrollOffsetX;
  set scrollOffsetX(ViewportOffset? value) {
    if (value == _scrollOffsetX) return;
    _scrollOffsetX?.removeListener(_scrollXListener);
    _scrollOffsetX = value;
    _scrollOffsetX?.addListener(_scrollXListener);
  }

  ViewportOffset? get scrollOffsetY => _scrollOffsetY;
  ViewportOffset? _scrollOffsetY;
  set scrollOffsetY(ViewportOffset? value) {
    if (value == _scrollOffsetY) return;
    _scrollOffsetY?.removeListener(_scrollYListener);
    _scrollOffsetY = value;
    _scrollOffsetY?.addListener(_scrollYListener);
  }

  void _scrollXListener() {
    assert(scrollListener != null);
    // If scroll is happening, that element has been unmounted, prevent null usage.
    if (scrollOffsetX != null) {
      scrollListener!(scrollOffsetX!.pixels, AxisDirection.right);
      RenderBoxModel renderBoxModel = this.renderBoxModel!;
      renderBoxModel.markNeedsPaint();
    }
  }

  void _scrollYListener() {
    assert(scrollListener != null);
    if (scrollOffsetY != null) {
      scrollListener!(scrollOffsetY!.pixels, AxisDirection.down);
      RenderBoxModel renderBoxModel = this.renderBoxModel!;
      renderBoxModel.markNeedsPaint();
    }
  }
  void disposeScrollable() {
    scrollListener = null;
    scrollablePointerListener = null;
    _scrollOffsetX = null;
    _scrollOffsetY = null;
    _scrollableX?.position?.dispose();
    _scrollableY?.position?.dispose();
    _scrollableX = null;
    _scrollableY = null;
  }

  void updateScrollOffsetX(ScrollListener _scrollListener) {
    if (renderBoxModel is RenderSliverListLayout) {
      RenderSliverListLayout renderBoxModel = this.renderBoxModel as RenderSliverListLayout;
      scrollOffsetX = renderBoxModel.axis == Axis.horizontal
        ? renderBoxModel.scrollable.position : null;
    } else if (renderBoxModel != null) {
      CSSOverflowType overflowX = renderStyle.effectiveOverflowX;
      switch(overflowX) {
        case CSSOverflowType.hidden:
        case CSSOverflowType.auto:
        case CSSOverflowType.scroll:
          // Scrollable state should be maintained when values changes between hidden, auto, scroll.
          if (scrollOffsetX == null) {
            _scrollableX = KrakenScrollable(axisDirection: AxisDirection.right, scrollListener: _scrollListener);
            scrollOffsetX = _scrollableX!.position;
          }
          // Content in overflow hidden container can only be scrolled programmatically but not by direct intervention of user.
          // https://www.w3.org/TR/css-overflow-3/#valdef-overflow-hidden
          bool canDrag = overflowX != CSSOverflowType.hidden;
          _scrollableX!.setCanDrag(canDrag);
          break;
        case CSSOverflowType.visible:
        case CSSOverflowType.clip:
        default:
          _scrollableX = null;
          scrollOffsetX == null;
          break;
      }

      if (scrollOffsetX != null || scrollOffsetY != null) {
        scrollListener = _scrollListener;
        scrollablePointerListener = _scrollablePointerListener;
      } else {
        scrollListener = null;
        scrollablePointerListener = null;
      }
    }
  }

  void updateScrollOffsetY(ScrollListener _scrollListener) {
    if (renderBoxModel is RenderSliverListLayout) {
      RenderSliverListLayout renderBoxModel = this.renderBoxModel as RenderSliverListLayout;
      scrollOffsetY = renderBoxModel.axis == Axis.vertical
        ? renderBoxModel.scrollable.position : null;
    } else if (renderBoxModel != null) {
      CSSOverflowType overflowY = renderStyle.effectiveOverflowY;
      switch(overflowY) {
        case CSSOverflowType.hidden:
        case CSSOverflowType.auto:
        case CSSOverflowType.scroll:
          // Scrollable state should be maintained when values changes between hidden, auto, scroll.
          if (scrollOffsetY == null) {
            _scrollableY = KrakenScrollable(axisDirection: AxisDirection.down, scrollListener: _scrollListener);
            scrollOffsetY = _scrollableY!.position;
          }
          // Content in overflow hidden container can only be scrolled programmatically but not by direct intervention of user.
          // https://www.w3.org/TR/css-overflow-3/#valdef-overflow-hidden
          bool canDrag = overflowY != CSSOverflowType.hidden;
          _scrollableY!.setCanDrag(canDrag);
          break;
        case CSSOverflowType.clip:
        case CSSOverflowType.visible:
        default:
          _scrollableY = null;
          scrollOffsetY == null;
          break;
      }

      if (scrollOffsetX != null || scrollOffsetY != null) {
        scrollListener = _scrollListener;
        scrollablePointerListener = _scrollablePointerListener;
      } else {
        scrollListener = null;
        scrollablePointerListener = null;
      }
    }
  }

  void scrollingContentBoxStyleListener(String property, String? original, String present) {
    RenderLayoutBox? scrollingContentBox = (renderBoxModel as RenderLayoutBox).renderScrollingContent;
    // Sliver content has no multi scroll content box.
    if (scrollingContentBox == null) return;

    CSSRenderStyle scrollingContentRenderStyle = scrollingContentBox.renderStyle;

    switch (property) {
      case DISPLAY:
        scrollingContentRenderStyle.display = renderStyle.display;
        break;
      case LINE_HEIGHT:
        scrollingContentRenderStyle.lineHeight = renderStyle.lineHeight;
        break;
      case TEXT_ALIGN:
        scrollingContentRenderStyle.textAlign = renderStyle.textAlign;
        break;
      case WHITE_SPACE:
        scrollingContentRenderStyle.whiteSpace = renderStyle.whiteSpace;
        break;
      case FLEX_DIRECTION:
        scrollingContentRenderStyle.flexDirection = renderStyle.flexDirection;
        break;
      case FLEX_WRAP:
        scrollingContentRenderStyle.flexWrap = renderStyle.flexWrap;
        break;
      case ALIGN_CONTENT:
        scrollingContentRenderStyle.alignContent = renderStyle.alignContent;
        break;
      case ALIGN_ITEMS:
        scrollingContentRenderStyle.alignItems = renderStyle.alignItems;
        break;
      case ALIGN_SELF:
        scrollingContentRenderStyle.alignSelf = renderStyle.alignSelf;
        break;
      case JUSTIFY_CONTENT:
        scrollingContentRenderStyle.justifyContent = renderStyle.justifyContent;
        break;
      case COLOR:
        scrollingContentRenderStyle.color = renderStyle.color;
        break;
      case TEXT_DECORATION_LINE:
        scrollingContentRenderStyle.textDecorationLine = renderStyle.textDecorationLine;
        break;
      case TEXT_DECORATION_COLOR:
        scrollingContentRenderStyle.textDecorationColor = renderStyle.textDecorationColor;
        break;
      case TEXT_DECORATION_STYLE:
        scrollingContentRenderStyle.textDecorationStyle = renderStyle.textDecorationStyle;
        break;
      case FONT_WEIGHT:
        scrollingContentRenderStyle.fontWeight = renderStyle.fontWeight;
        break;
      case FONT_STYLE:
        scrollingContentRenderStyle.fontStyle = renderStyle.fontStyle;
        break;
      case FONT_FAMILY:
        scrollingContentRenderStyle.fontFamily = renderStyle.fontFamily;
        break;
      case FONT_SIZE:
        scrollingContentRenderStyle.fontSize = renderStyle.fontSize;
        break;
      case LETTER_SPACING:
        scrollingContentRenderStyle.letterSpacing = renderStyle.letterSpacing;
        break;
      case WORD_SPACING:
        scrollingContentRenderStyle.wordSpacing = renderStyle.wordSpacing;
        break;
      case TEXT_SHADOW:
        scrollingContentRenderStyle.textShadow = renderStyle.textShadow;
        break;
      case TEXT_OVERFLOW:
        scrollingContentRenderStyle.textOverflow = renderStyle.textOverflow;
        break;
      case LINE_CLAMP:
        scrollingContentRenderStyle.lineClamp = renderStyle.lineClamp;
        break;
    }
  }

  // Update renderBox according to overflow value.
  void updateOverflowRenderBox() {
    // Sliver has no scrolling content box.
    if (renderBoxModel is RenderSliverListLayout) return;

    CSSOverflowType effectiveOverflowY = renderStyle.effectiveOverflowY;
    CSSOverflowType effectiveOverflowX = renderStyle.effectiveOverflowX;

    if (renderBoxModel is RenderLayoutBox) {
      // Create two repaintBoundary for scroll container if any direction is scrollable.
      bool shouldScrolling = (effectiveOverflowX == CSSOverflowType.auto || effectiveOverflowX == CSSOverflowType.scroll)
        || (effectiveOverflowY == CSSOverflowType.auto || effectiveOverflowY == CSSOverflowType.scroll);

      if (shouldScrolling) {
        _attachScrollingContentBox();
      } else {
        _detachScrollingContentBox();
      }
    }
  }

  void updateScrollingContentBox() {
    _detachScrollingContentBox();
    _attachScrollingContentBox();
  }

  // Create two repaintBoundary for an overflow scroll container.
  // Outer repaintBoundary avoid repaint of parent and sibling renderObjects when scrolling.
  // Inner repaintBoundary avoid repaint of child renderObjects when scrolling.
  void _attachScrollingContentBox() {
    RenderLayoutBox outerLayoutBox = renderBoxModel as RenderLayoutBox;
    RenderLayoutBox? scrollingContentBox = outerLayoutBox.renderScrollingContent;
    if (scrollingContentBox != null) {
      return;
    }

    Element element = this as Element;
    // If outer scrolling box already has children in the case of element already attached,
    // move them into the children of inner scrolling box.
    List<RenderBox> children = outerLayoutBox.detachChildren();

    RenderLayoutBox renderScrollingContent = element.createScrollingContentLayout();
    renderScrollingContent.addAll(children);

    outerLayoutBox.add(renderScrollingContent);
    element.style.addStyleChangeListener(scrollingContentBoxStyleListener);

    // Manually copy already set filtered styles to the renderStyle of scrollingContentLayoutBox.
    _scrollingContentBoxCopyStyles.forEach((String styleProperty) {
      scrollingContentBoxStyleListener(styleProperty, null, '');
    });
  }

  void _detachScrollingContentBox() {
    RenderLayoutBox outerLayoutBox = renderBoxModel as RenderLayoutBox;
    RenderLayoutBox? scrollingContentBox = outerLayoutBox.renderScrollingContent;
    if (scrollingContentBox == null) return;

    List<RenderBox> children = scrollingContentBox.detachChildren();
    // Remove scrolling content box.
    outerLayoutBox.remove(scrollingContentBox);

    (this as Element).style.removeStyleChangeListener(scrollingContentBoxStyleListener);
    // Move children of scrolling content box to the children to outer layout box.
    outerLayoutBox.addAll(children);
  }

  void _scrollablePointerListener(PointerEvent event) {
    if (event is PointerDownEvent) {
      if (_scrollableX != null) {
        _scrollableX!.handlePointerDown(event);
      }
      if (_scrollableY != null) {
        _scrollableY!.handlePointerDown(event);
      }
    }
  }

  double get scrollTop {
    KrakenScrollable? scrollableY = _getScrollable(Axis.vertical);
    if (scrollableY != null) {
      return scrollableY.position?.pixels ?? 0;
    }
    return 0.0;
  }
  set scrollTop(double value) {
    _scrollTo(y: value);
  }

  void scroll(double x, double y) {
    _scrollTo(x: x, y: y, withAnimation: false);
  }

  void scrollBy(double x, double y) {
    _scrollBy(dx: x, dy: y, withAnimation: false);
  }

  void scrollTo(double x, double y) {
    _scrollTo(x: x, y: y, withAnimation: false);
  }

  double get scrollLeft {
    KrakenScrollable? scrollableX = _getScrollable(Axis.horizontal);
    if (scrollableX != null) {
      return scrollableX.position?.pixels ?? 0;
    }
    return 0.0;
  }
  set scrollLeft(double value) {
    _scrollTo(x: value);
  }

  int get scrollHeight {
    KrakenScrollable? scrollable = _getScrollable(Axis.vertical);
    if (scrollable?.position?.maxScrollExtent != null) {
      // Viewport height + maxScrollExtent
      return renderBoxModel!.clientHeight + scrollable!.position!.maxScrollExtent.toInt();
    }

    Size scrollContainerSize = renderBoxModel!.scrollableSize;
    return scrollContainerSize.height.toInt();
  }

  int get scrollWidth {
    KrakenScrollable? scrollable = _getScrollable(Axis.horizontal);
    if (scrollable?.position?.maxScrollExtent != null) {
      return renderBoxModel!.clientWidth + scrollable!.position!.maxScrollExtent.toInt();
    }
    Size scrollContainerSize = renderBoxModel!.scrollableSize;
    return scrollContainerSize.width.toInt();
  }

  int get clientTop => renderBoxModel?.renderStyle.effectiveBorderTopWidth.computedValue.toInt() ?? 0;

  int get clientLeft => renderBoxModel?.renderStyle.effectiveBorderLeftWidth.computedValue.toInt() ?? 0;

  int get clientWidth => renderBoxModel?.clientWidth ?? 0;

  int get clientHeight => renderBoxModel?.clientHeight ?? 0;

  int get offsetWidth {
    RenderBoxModel? renderBox = renderBoxModel;
    if (renderBox == null) {
      return 0;
    }
    return renderBox.hasSize ? renderBox.size.width.toInt() : 0;
  }

  int get offsetHeight {
    RenderBoxModel? renderBox = renderBoxModel;
    if (renderBox == null) {
      return 0;
    }
    return renderBox.hasSize ? renderBox.size.height.toInt() : 0;
  }

  void _scrollBy({ double dx = 0.0, double dy = 0.0, bool? withAnimation }) {
    if (dx != 0) {
      _scroll(scrollLeft + dx, Axis.horizontal, withAnimation: withAnimation);
    }
    if (dy != 0) {
      _scroll(scrollTop + dy, Axis.vertical, withAnimation: withAnimation);
    }
  }


  void _scrollTo({ double? x, double? y, bool? withAnimation }) {
    if (x != null) {
      _scroll(x, Axis.horizontal, withAnimation: withAnimation);
    }

    if (y != null) {
      _scroll(y, Axis.vertical, withAnimation: withAnimation);
    }
  }

  KrakenScrollable? _getScrollable(Axis direction) {
    KrakenScrollable? scrollable;
    if (renderer is RenderSliverListLayout) {
      RenderSliverListLayout recyclerLayout = renderer as RenderSliverListLayout;
      scrollable = direction == recyclerLayout.axis ? recyclerLayout.scrollable : null;
    } else {
      if (direction == Axis.horizontal) {
        scrollable = _scrollableX;
      } else if (direction == Axis.vertical) {
        scrollable = _scrollableY;
      }
    }
    return scrollable;
  }

  void _scroll(num aim, Axis direction, { bool? withAnimation = false }) {
    KrakenScrollable? scrollable = _getScrollable(direction);
    if (scrollable != null) {
      double distance = aim.toDouble();

      // Apply scroll effect after layout.
      assert(isRendererAttached, 'Overflow can only be added to a RenderBox.');
      renderer!.owner!.flushLayout();

      scrollable.position!.moveTo(distance,
        duration: withAnimation == true ? SCROLL_DURATION : null,
        curve: withAnimation == true ? Curves.easeOut : null,
      );
    }
  }
}

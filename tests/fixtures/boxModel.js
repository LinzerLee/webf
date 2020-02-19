function setStyle(dom, object) {
  for (let key in object) {
    if (object.hasOwnProperty(key)) {
      dom.style[key] = object[key];
    }
  }
}

const container1 = document.createElement('div');
setStyle(container1, {
  padding: '20rpx', backgroundColor: '#999', margin: '40rpx', border: '5px solid #000'
});

const container2 = document.createElement('div');
setStyle(container2, {
  padding: '20rpx', backgroundColor: '#666', margin: '40rpx', border: '5px solid #000'
});

const container3 = document.createElement('div');
setStyle(container3, {
  padding: '20rpx', height: '100rpx', backgroundColor: '#f40', margin: '40rpx', border: '5px solid #000'
});

const textNode = document.createTextNode('Hello World');
document.body.appendChild(container1);
container1.appendChild(container2);
container2.appendChild(container3);
container3.appendChild(textNode);

#import "@local/modern-cug-report:0.1.3": *
#show: doc => template(doc, footer: "", header: "")


= 1 Proxifier

- https://www.proxifier.com
- https://www.proxifier.com/download/ProxifierSetup.exe

设置某个软件走全局代理。

*激活码*
https://gist.github.com/montasim/11e313f82dc6c2aea28298941158429f

```text
KFZUS-F3JGV-T95Y7-BXGAS-5NHHP
T3ZWQ-P2738-3FJWS-YE7HT-6NA3K
KFZUS-F3JGV-T95Y7-BXGAS-5NHHP
65Z2L-P36BY-YWJYC-TMJZL-YDZ2S
SFZHH-2Y246-Z483L-EU92B-LNYUA
GSZVS-5W4WA-T9F2E-L3XUX-68473
FTZ8A-R3CP8-AVHYW-KKRMQ-SYDLS
Q3ZWN-QWLZG-32G22-SCJXZ-9B5S4
DAZPH-G39D3-R4QY7-9PVAY-VQ6BU
KLZ5G-X37YY-65ZYN-EUSV7-WPPBS
6JZUY-32TKX-TK9W7-DU387-9RWKZ
L6Z8A-XY2J4-BTZ3P-ZZ7DF-A2Q9C（Portable Edition）
5EZ8G-C3WL5-B56YG-SCXM9-6QZAP（Standard Edition）
P427L-9Y552-5433E-8DSR3-58Z68（MAC）
```

#figure(
  image("Figures/Proxifier.png", width: 100%),
  caption: [
    Proxifier接管AntiGravity的全部网络请求
  ],
) <fig_>

#pagebreak()

= 2 AntiGravity

Extension设置为微软链接。

```json
{
  "antigravity.marketplaceGalleryItemURL": 
    "https://marketplace.visualstudio.com/items",
  "antigravity.marketplaceExtensionGalleryServiceURL": 
    "https://marketplace.visualstudio.com/_apis/public/gallery",
}
```

白嫖Genimi3 Pro和Claude 4.5。界面与VSCode类似。

#figure(
  image("Figures/AntiGravity.png", width: 70%),
  caption: [
    AntiGravity主界面。5个小时免费使用额度用完后需要等待下一个周期。
  ]
) <fig_>

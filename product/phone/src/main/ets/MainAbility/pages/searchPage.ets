/**
 * Copyright (c) 2021 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
import LogUtil from '../../../../../../../common/utils/src/main/ets/default/baseUtil/LogUtil';
import Log from '../../../../../../../common/utils/src/main/ets/default/baseUtil/LogDecorator';
import ResultComponent from '../../../../../../../common/search/src/main/ets/default/page/resultComponent';
import SearchHeader from '../../../../../../../common/search/src/main/ets/default/page/searchHeader';
import ConfigData from '../../../../../../../common/utils/src/main/ets/default/baseUtil/ConfigData';
import SearchModel from '../../../../../../../common/search/src/main/ets/default/model/SearchModel';
import SearchUtil from '../../../../../../../common/search/src/main/ets/default/common/SearchUtil';
import SearchData from '../../../../../../../common/search/src/main/ets/default/model/SearchData';
import ResourceUtil from '../../../../../../../common/search/src/main/ets/default/common/ResourceUtil';
import SEARCH_DATA_CONFIG from '../model/search/SearchDataConfig';
import Router from '@system.router'


/**
 * search page
 */
@Entry
@Component
struct SearchPage {
  @State @Watch('setSearchKeyword') inputKeyword: string = ''
  @State @Watch('doSearch') searchKeyword: string = ''
  @State searchResultList: SearchData[][] = []
  private searchModel: SearchModel;
  @State listSpace: string = '12vp'

  build() {
    Column(){
      GridContainer({columns:12, sizeType: SizeType.Auto, gutter: vp2px(1) === 2 ? '12vp' : '0vp', margin: vp2px(1) === 2 ? '24vp' : '0vp'}) {
        Row({}) {
          Column() {
          }
          .width(ConfigData.WH_100_100)
          .height(ConfigData.WH_100_100)
          .useSizeType({
            xs: { span: 0, offset: 0 }, sm: { span: 0, offset: 0 },
            md: { span: 0, offset: 0 }, lg: { span: 2, offset: 0 }
          });

          Column() {
            SearchHeader({ inputKeyword: $inputKeyword })

            if (this.searchKeyword) {

              // search result exist
              if (this.searchResultList && this.searchResultList.length > 0) {

                List({ space: this.listSpace }) {

                  // search result list
                  ForEach(this.searchResultList, (eachBlock) => {
                    ListItem() {
                      List() {

                        // item
                        ForEach(eachBlock.map((item2, index2) => {
                          return { index: index2, data: item2 }
                        }), (item) => {

                          ListItem() {
                            Column() {
                              Navigator({ target: item.data.uri }) {
                                ResultComponent({
                                  highlightKeyword: $searchKeyword,
                                  icon: item.index == 0 ? item.data.icon : '',
                                  data: item.data
                                });
                              }
                            }
                          }
                        })
                      }
                      .width(ConfigData.WH_100_100)
                      .divider({
                        strokeWidth: 1,
                        color: $r('app.color.color_E3E3E3_grey'),
                        startMargin: $r('app.float.wh_value_60'),
                        endMargin: $r('app.float.wh_value_20')
                      })
                      .borderRadius($r("sys.float.ohos_id_corner_radius_default_l"))
                      .backgroundColor($r("sys.color.ohos_id_color_foreground_contrary"))
                      .padding($r('app.float.distance_4'))
                    }
                  })
                }
                .width(ConfigData.WH_100_100)

              } else {
                // search no match
                Column() {
                  Image($r("app.media.img_search_no_result"))
                    .width($r("app.float.search_no_result_image_size"))
                    .height($r("app.float.search_no_result_image_size"))

                  // search no match
                  Text($r("app.string.searchNoResult"))
                    .fontSize($r("app.float.search_no_result_text_font_size"))
                    .fontColor($r("app.color.font_color_182431"))
                    .fontWeight(FontWeight.Medium)
                    .alignSelf(ItemAlign.Center);
                }
                .alignItems(HorizontalAlign.Center)
                .margin({ top: $r("app.float.search_no_result_margin_top")})
              }
            }
          }
          .width(ConfigData.WH_100_100)
          .height(ConfigData.WH_100_100)
          .padding({ left: $r('app.float.distance_24'), right: $r('app.float.distance_24') })
          .useSizeType({
            xs: { span: 12, offset: 0 }, sm: { span: 12, offset: 0 },
            md: { span: 12, offset: 0 }, lg: { span: 8, offset: 2 }
          });

          Column() {
          }
          .width(ConfigData.WH_100_100)
          .height(ConfigData.WH_100_100)
          .useSizeType({
            xs: { span: 0, offset: 12 }, sm: { span: 0, offset: 12 },
            md: { span: 0, offset: 12 }, lg: { span: 2, offset: 10 }
          })
        }
        .width(ConfigData.WH_100_100)
        .height(ConfigData.WH_100_100);
      }
      .width(ConfigData.WH_100_100)
      .height(ConfigData.WH_100_100);
    }
    .backgroundColor($r("sys.color.ohos_id_color_sub_background"))
    .width(ConfigData.WH_100_100)
    .height(ConfigData.WH_100_100);
  }

  @Log
  aboutToAppear(): void {
    ResourceUtil.getString($r('app.float.distance_12')).then(value => this.listSpace = value);

    // init search data
    this.searchModel = new SearchModel(SEARCH_DATA_CONFIG);
    this.searchModel.initSearchData()
      .then(() => {
        LogUtil.debug(ConfigData.TAG + 'searchPage aboutToAppear initSearchData complete');
        this.doSearch()
      })
  }

  @Log
  onBackPress() {
    Router.back();
  }

  /**
   * set search keyword
   */
  @Log
  setSearchKeyword() {
    this.searchKeyword = SearchUtil.stripKeyword(this.inputKeyword).trim()
  }

  /**
   * search
   */
  @Log
  doSearch() {
    this.searchModel.search(this.searchKeyword)
      .then((result: SearchData[]) => {
        LogUtil.debug(ConfigData.TAG + 'searchPage doSearch : search : searchKeyword = ' +
        this.searchKeyword + '; => then data = ' + JSON.stringify(result));
        this.searchResultList = undefined
        this.searchResultList = this.makeViewData(result)
        LogUtil.debug(ConfigData.TAG + 'searchPage doSearch : searchResultList = ' + JSON.stringify(this.searchResultList));
      })
  }

  /**
   * make data for view
   *
   * @param result Search result
   * @return Data for show to view
   */
  @Log
  makeViewData(result: SearchData[]) : SearchData[][]  {

    let list: SearchData[][] = [];
    let group: SearchData[] = undefined;

    let lastUri = undefined
    for (var i = 0; i < result.length; i++) {
      let data = result[i];

      if (data.uri !== lastUri) {
        if (group) {
          let g = group;
          list.push(g);
        }
        group = []
        lastUri = data.uri
      }
      group.push(data)

      if (i == result.length - 1) {
        list.push(group);
      }
    }

    return list
  }

}

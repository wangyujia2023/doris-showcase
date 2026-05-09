<template>
  <div>
    <el-tabs v-model="activeTab" type="card" style="margin-bottom:0">
      <el-tab-pane :label="t('ut.capOverview')" name="capabilities" />
      <el-tab-pane :label="t('ut.crowdBuild')" name="crowd" />
      <el-tab-pane :label="t('ut.portrait')" name="portrait" />
      <el-tab-pane :label="t('ut.mapPush')" name="map" />
      <el-tab-pane :label="t('ut.tagAnalysis')" name="taganalysis" />
      <el-tab-pane :label="t('ut.wideQuery')" name="wide" />
      <el-tab-pane :label="t('ut.behavior')" name="behavior" />
      <el-tab-pane :label="t('etl')" name="ETL" />
    </el-tabs>

    <!-- ═══════════════════ 能力概览 ═══════════════════ -->
    <CapabilityOverview v-if="activeTab === 'capabilities'" />

    <!-- ═══════════════════ 人群包构建 ═══════════════════ -->
    <div v-if="activeTab === 'crowd'" class="card" style="border-top-left-radius:0">
      <el-row :gutter="16">
        <!-- 左侧：标签选择 -->
        <el-col :span="14">
          <div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:10px">
            <span style="font-size:13px;font-weight:600">{{ t('ut.tagSelect') }}</span>
            <div style="display:flex;gap:8px">
              <el-tag type="success" size="small">{{ t('ut.include') }} {{ includeTagIds.length }}</el-tag>
              <el-tag type="danger" size="small">{{ t('ut.exclude') }} {{ excludeTagIds.length }}</el-tag>
            </div>
          </div>
          <div v-for="grp in tagMeta" :key="grp.category" style="margin-bottom:12px">
            <div style="font-size:11px;color:#909399;margin-bottom:5px;text-transform:uppercase;letter-spacing:.5px">{{ groupLabel(grp.category) }}</div>
            <div style="display:flex;flex-wrap:wrap;gap:6px">
              <div
                v-for="t in grp.tags" :key="t.tag_id"
                @click="toggleInclude(t.tag_id)"
                @contextmenu.prevent="toggleExclude(t.tag_id)"
                :class="tagClass(t.tag_id)"
                class="tag-chip"
              >{{ tagLabel(t.tag_id) }}</div>
            </div>
          </div>
        </el-col>

        <!-- 右侧：当前圈选 + 操作 -->
        <el-col :span="10">
          <div style="background:#f5f7fa;border-radius:6px;padding:14px">
            <div style="font-size:13px;font-weight:600;margin-bottom:10px">{{ t('ut.estimate') }}</div>
            <div style="margin-bottom:8px">
              <div style="font-size:12px;color:#67c23a;margin-bottom:4px">✓ {{ t('ut.include') }}</div>
              <el-tag
                v-for="tid in includeTagIds" :key="tid" type="success" closable size="small"
                @close="includeTagIds = includeTagIds.filter(x=>x!==tid)"
                style="margin:2px"
              >{{ tagLabel(tid) }}</el-tag>
              <span v-if="!includeTagIds.length" style="font-size:12px;color:#c0c4cc">({{ t('ut.any') }})</span>
            </div>
            <div style="margin-bottom:12px">
              <div style="font-size:12px;color:#f56c6c;margin-bottom:4px">✗ {{ t('ut.exclude') }}</div>
              <el-tag
                v-for="tid in excludeTagIds" :key="tid" type="danger" closable size="small"
                @close="excludeTagIds = excludeTagIds.filter(x=>x!==tid)"
                style="margin:2px"
              >{{ tagLabel(tid) }}</el-tag>
              <span v-if="!excludeTagIds.length" style="font-size:12px;color:#c0c4cc">({{ t('ut.none') }})</span>
            </div>

            <el-button type="primary" size="small" :loading="bitmapLoading" @click="computeBitmapCrowd" style="width:100%;margin-bottom:10px">
              {{ t('ut.bitmapEstimate') }}
            </el-button>

            <div v-if="crowdSize !== null" style="text-align:center;margin-bottom:12px">
              <div style="font-size:28px;font-weight:700;color:#409eff">{{ crowdSize.toLocaleString() }}</div>
              <div style="font-size:12px;color:#909399">{{ t('ut.coveredUsers') }}</div>
            </div>

            <el-divider />
            <div style="font-size:13px;font-weight:600;margin-bottom:8px">{{ t('ut.saveCrowd') }}</div>
            <el-input v-model="crowdName" :placeholder="t('ut.crowdName')" size="small" style="margin-bottom:6px" />
            <el-input v-model="crowdDesc" :placeholder="t('ut.descOpt')" size="small" style="margin-bottom:8px" />
            <el-button type="success" size="small" :disabled="!crowdName || crowdSize === null" @click="saveCrowd" style="width:100%">
              {{ t('ut.saveCrowd') }}
            </el-button>
          </div>
        </el-col>
      </el-row>

      <!-- 人群包列表 -->
      <el-divider>{{ t('ut.savedCrowd') }}</el-divider>
      <el-row :gutter="12" style="margin-bottom:10px;align-items:center">
        <el-col :span="20">
          <el-checkbox-group v-model="compareIds" :max="2" style="display:inline">
            <el-checkbox v-for="pkg in crowdList" :key="pkg.crowd_id" :value="pkg.crowd_id" style="margin:0 8px 8px 0">
              <el-card shadow="hover" style="width:220px;display:inline-block;vertical-align:top;cursor:pointer">
                <div style="font-size:13px;font-weight:600">{{ pkg.name }}</div>
                <div style="font-size:11px;color:#909399;margin:3px 0">{{ pkg.desc || '—' }}</div>
                <div style="font-size:12px;color:#409eff">{{ pkg.crowd_size.toLocaleString() }} {{ t('ut.peopleUnit') }}</div>
                <div style="font-size:11px;color:#c0c4cc;margin-top:4px">{{ pkg.created_at }}</div>
                <el-button size="small" type="danger" text @click.stop="deleteCrowd(pkg.crowd_id)" style="position:absolute;top:6px;right:6px">{{ t('common.delete') }}</el-button>
              </el-card>
            </el-checkbox>
          </el-checkbox-group>
        </el-col>
        <el-col :span="4">
          <el-button type="primary" :disabled="compareIds.length !== 2" :loading="compareLoading" @click="runCompare">
            {{ t('ut.compare') }}
          </el-button>
        </el-col>
      </el-row>

      <!-- 对比结果 -->
      <div v-if="compareResult">
        <el-divider>{{ t('ut.compareTitle') }}：{{ compareResult.pkg_a.name }} vs {{ compareResult.pkg_b.name }}</el-divider>
        <el-table :data="compareResult.diffs.slice(0,20)" border size="small">
          <el-table-column :label="t('ut.tag')" width="140">
            <template #default="{row}">{{ tagText(row.label) }}</template>
          </el-table-column>
          <el-table-column :label="t('ut.category')" width="80">
            <template #default="{row}">{{ groupLabel(row.category) }}</template>
          </el-table-column>
          <el-table-column :label="t('ut.pkgA')" width="160">
            <template #default="{row}">
              <el-progress :percentage="Math.min(row.pct_a,100)" :stroke-width="8" :format="()=>row.pct_a+'%'" />
            </template>
          </el-table-column>
          <el-table-column :label="t('ut.pkgB')" width="160">
            <template #default="{row}">
              <el-progress :percentage="Math.min(row.pct_b,100)" :stroke-width="8" :format="()=>row.pct_b+'%'" />
            </template>
          </el-table-column>
          <el-table-column :label="t('ut.diff')" width="90">
            <template #default="{row}">
              <span :style="{color: row.diff>0?'#67c23a':row.diff<0?'#f56c6c':'#909399'}">
                {{ row.diff > 0 ? '+' : '' }}{{ row.diff }}%
              </span>
            </template>
          </el-table-column>
        </el-table>
      </div>
    </div>

    <!-- ═══════════════════ 人群画像 ═══════════════════ -->
    <div v-if="activeTab === 'portrait'" class="card" style="border-top-left-radius:0">
      <el-tabs v-model="portraitTab" type="border-card">
        <!-- TGI -->
        <el-tab-pane :label="t('ut.tgiTab')" name="tgi">
          <div style="margin:10px 0;display:flex;gap:8px;align-items:center;flex-wrap:wrap">
            <span style="font-size:13px">{{ t('ut.targetTags') }}：</span>
            <el-select v-model="tgiTagIds" multiple collapse-tags collapse-tags-tooltip :placeholder="t('ut.optionalAll')" style="width:320px">
              <el-option-group v-for="grp in tagMeta" :key="grp.category" :label="groupLabel(grp.category)">
                <el-option v-for="tg in grp.tags" :key="tg.tag_id" :label="tagLabel(tg.tag_id)" :value="tg.tag_id" />
              </el-option-group>
            </el-select>
            <el-button type="primary" :loading="tgiLoading" @click="runTgi">{{ t('ut.analyze') }}</el-button>
          </div>
          <div v-if="tgiData.length">
            <el-select v-model="tgiCat" :placeholder="t('ut.filterByCategory')" clearable size="small" style="margin-bottom:10px;width:160px">
              <el-option v-for="c in tgiCats" :key="c" :label="groupLabel(c)" :value="c" />
            </el-select>
            <v-chart :option="tgiOption" style="height:420px" autoresize />
            <div style="font-size:12px;color:#909399;margin-top:6px">
              {{ t('ut.tgiFormula') }}
            </div>
          </div>
        </el-tab-pane>

        <!-- 交叉分析 -->
        <el-tab-pane :label="t('ut.crossTab')" name="cross">
          <div style="margin:10px 0;display:flex;gap:12px;align-items:center">
            <el-select v-model="crossCat1" :placeholder="t('ut.categoryA')" style="width:150px">
              <el-option v-for="c in allCats" :key="c" :label="groupLabel(c)" :value="c" />
            </el-select>
            <span>×</span>
            <el-select v-model="crossCat2" :placeholder="t('ut.categoryB')" style="width:150px">
              <el-option v-for="c in allCats" :key="c" :label="groupLabel(c)" :value="c" />
            </el-select>
            <el-button type="primary" :loading="crossLoading" @click="runCross">{{ t('ut.crossTab') }}</el-button>
          </div>
          <div v-if="crossData">
            <div style="overflow-x:auto">
              <table class="cross-matrix">
                <thead>
                  <tr>
                    <th>{{ groupLabel(crossCat1) }} \ {{ groupLabel(crossCat2) }}</th>
                    <th v-for="l in crossData.tags2" :key="l">{{ tagText(l) }}</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="row in crossData.matrix" :key="row.label">
                    <td style="font-weight:600;background:#f5f7fa">{{ tagText(row.label) }}</td>
                    <td
                      v-for="cell in row.cells" :key="cell"
                      :style="{ background: crossColor(cell.pct, crossMaxPct) }"
                      :title="`${cell.count} ${t('ut.peopleUnit')} / ${cell.pct}%`"
                    >{{ cell.pct }}%</td>
                  </tr>
                </tbody>
              </table>
            </div>
            <div style="font-size:12px;color:#909399;margin-top:6px">{{ t('ut.crossHint').replace('{0}', crossData.total.toLocaleString()) }}</div>
          </div>
        </el-tab-pane>

        <!-- 地域分布 -->
        <el-tab-pane :label="t('ut.geoTab')" name="geo">
          <div style="margin:10px 0;display:flex;gap:8px;align-items:center">
            <span style="font-size:13px">{{ t('ut.filterTags') }}：</span>
            <el-select v-model="geoTagIds" multiple collapse-tags :placeholder="t('ut.optionalAll')" style="width:280px">
              <el-option-group v-for="grp in tagMeta" :key="grp.category" :label="groupLabel(grp.category)">
                <el-option v-for="tg in grp.tags" :key="tg.tag_id" :label="tagLabel(tg.tag_id)" :value="tg.tag_id" />
              </el-option-group>
            </el-select>
            <el-button type="primary" :loading="geoLoading" @click="runGeo">{{ t('common.query') }}</el-button>
          </div>
          <div v-if="geoData">
            <el-row :gutter="16">
              <el-col :span="12">
                <v-chart :option="geoProvinceOption" style="height:380px" autoresize />
              </el-col>
              <el-col :span="12">
                <el-table :data="geoData.province_list.slice(0,15)" border size="small" max-height="360">
                  <el-table-column prop="province" :label="t('ut.province')" />
                  <el-table-column :label="t('ut.userCount')">
                    <template #default="{row}">
                      <el-progress :percentage="Math.round(row.cnt/geoData.province_list[0].cnt*100)" :stroke-width="8" :format="()=>row.cnt.toLocaleString()" />
                    </template>
                  </el-table-column>
                </el-table>
              </el-col>
            </el-row>
          </div>
        </el-tab-pane>
      </el-tabs>
    </div>

    <!-- ═══════════════════ 地图投放 ═══════════════════ -->
    <div v-if="activeTab === 'map'" class="card" style="border-top-left-radius:0">
      <el-row :gutter="20">
        <el-col :span="14">
          <div style="font-size:13px;font-weight:600;margin-bottom:10px">{{ t('ut.provinceSelectTitle') }}</div>
          <div style="display:flex;flex-wrap:wrap;gap:6px;margin-bottom:12px">
            <div
              v-for="p in provinces" :key="p"
              @click="toggleProvince(p)"
              :class="['province-chip', selectedProvinces.includes(p) ? 'selected' : '']"
            >{{ displayProvince(p) }}</div>
          </div>
          <div style="margin-bottom:12px">
            <el-tag v-if="!selectedProvinces.length" type="info" size="small">{{ t('ut.noProvince') }}</el-tag>
            <el-tag v-for="p in selectedProvinces" :key="p" closable @close="selectedProvinces = selectedProvinces.filter(x=>x!==p)" style="margin:2px">{{ displayProvince(p) }}</el-tag>
          </div>
          <el-button type="primary" :loading="mapLoading" :disabled="!selectedProvinces.length" @click="runTargeting">
            {{ t('ut.estimateDelivery') }}
          </el-button>

          <div v-if="targetingData" style="margin-top:16px">
            <el-row :gutter="12" style="margin-bottom:12px">
              <el-col :span="8">
                <div class="stat-card">
                  <div class="stat-label">{{ t('ut.coveredUsers') }}</div>
                  <div class="stat-value" style="font-size:22px">{{ targetingData.total.toLocaleString() }}</div>
                </div>
              </el-col>
            </el-row>
            <el-table :data="targetingData.detail" border size="small">
              <el-table-column prop="province" :label="t('ut.province')" width="100" />
              <el-table-column :label="t('ut.userCount')" prop="cnt">
                <template #default="{row}">{{ (row.cnt||0).toLocaleString() }}</template>
              </el-table-column>
              <el-table-column :label="t('ut.avgAum')" prop="avg_aum">
                <template #default="{row}">¥{{ Number(row.avg_aum||0).toLocaleString() }}</template>
              </el-table-column>
              <el-table-column :label="t('ut.anomalyUsers')" prop="anomaly_cnt">
                <template #default="{row}">
                  <el-tag :type="row.anomaly_cnt>0?'danger':'success'" size="small">{{ row.anomaly_cnt||0 }}</el-tag>
                </template>
              </el-table-column>
            </el-table>
          </div>
        </el-col>

        <el-col :span="10">
          <div style="background:#f5f7fa;border-radius:6px;padding:16px">
            <div style="font-size:13px;font-weight:600;margin-bottom:12px">{{ t('ut.strategyConfig') }}</div>
            <el-form label-width="90px" size="small">
              <el-form-item :label="t('ut.deliveryChannel')">
                <el-checkbox-group v-model="strategy.channels">
                  <el-checkbox value="APP">{{ t('ut.channelApp') }}</el-checkbox>
                  <el-checkbox value="SMS">{{ t('ut.channelSms') }}</el-checkbox>
                  <el-checkbox value="EMAIL">{{ t('ut.channelEmail') }}</el-checkbox>
                  <el-checkbox value="WECHAT">{{ t('ut.channelWechat') }}</el-checkbox>
                </el-checkbox-group>
              </el-form-item>
              <el-form-item :label="t('ut.deliveryTime')">
                <el-time-picker v-model="strategy.timeStart" :placeholder="t('common.start')" style="width:100px" format="HH:mm" />
                <span style="margin:0 6px">-</span>
                <el-time-picker v-model="strategy.timeEnd" :placeholder="t('common.end')" style="width:100px" format="HH:mm" />
              </el-form-item>
              <el-form-item :label="t('ut.frequencyCap')">
                <el-input-number v-model="strategy.freqCap" :min="1" :max="10" />
                <span style="margin-left:6px;font-size:12px;color:#909399">{{ t('ut.timesPerDay') }}</span>
              </el-form-item>
              <el-form-item :label="t('ut.campaignTheme')">
                <el-input v-model="strategy.theme" :placeholder="t('ut.themePlaceholder')" />
              </el-form-item>
              <el-form-item>
                <el-button type="primary" @click="genStrategy">{{ t('ut.generateStrategy') }}</el-button>
              </el-form-item>
            </el-form>
            <div v-if="strategyPlan" style="margin-top:8px;padding:10px;background:#fff;border-radius:4px;font-size:12px;line-height:1.8;color:#303133">
              <div v-for="line in strategyPlan" :key="line">{{ line }}</div>
            </div>
          </div>
        </el-col>
      </el-row>
    </div>

    <!-- ═══════════════════ 标签分析 ═══════════════════ -->
    <div v-if="activeTab === 'taganalysis'" class="card" style="border-top-left-radius:0">
      <el-tabs v-model="taTab" type="border-card">
        <!-- 标签权重 -->
        <el-tab-pane :label="t('ut.weightTab')" name="weight">
          <div style="margin:10px 0;display:flex;gap:8px;align-items:center">
            <el-select v-model="weightTagIds" multiple collapse-tags :placeholder="t('ut.targetTags')" style="width:320px">
              <el-option-group v-for="grp in tagMeta" :key="grp.category" :label="groupLabel(grp.category)">
                <el-option v-for="tg in grp.tags" :key="tg.tag_id" :label="tagLabel(tg.tag_id)" :value="tg.tag_id" />
              </el-option-group>
            </el-select>
            <el-button type="primary" :loading="weightLoading" @click="runWeight">{{ t('ut.analyze') }}</el-button>
          </div>
          <div v-if="weightData">
            <el-row :gutter="16">
              <el-col v-for="cat in weightData.categories.slice(0,6)" :key="cat.category" :span="12" style="margin-bottom:16px">
                <div style="font-size:12px;font-weight:600;margin-bottom:6px">
                  {{ groupLabel(cat.category) }}
                  <el-tag size="small" style="margin-left:6px">{{ t('ut.avgTgi') }} {{ cat.avg_tgi }}</el-tag>
                </div>
                <div v-for="item in cat.tags.slice(0,5)" :key="item.tag_id" style="display:flex;align-items:center;gap:8px;margin-bottom:3px;font-size:12px">
                  <span style="width:80px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap">{{ tagText(item.label) }}</span>
                  <el-progress
                    :percentage="Math.min(item.tgi, 200)"
                    :stroke-width="8"
                    :color="item.tgi > 120 ? '#67c23a' : item.tgi > 80 ? '#409eff' : '#f56c6c'"
                    style="flex:1"
                    :format="() => item.tgi"
                  />
                </div>
              </el-col>
            </el-row>
          </div>
        </el-tab-pane>

        <!-- 异常检测 -->
        <el-tab-pane :label="t('ut.anomalyTab')" name="anomaly">
          <div style="margin:10px 0">
            <el-button type="warning" :loading="anomalyLoading" @click="runAnomaly">{{ t('ut.analyzeAnomaly') }}</el-button>
          </div>
          <div v-if="anomalyData">
            <el-row :gutter="12" style="margin-bottom:16px">
              <el-col :span="6">
                <div class="stat-card">
                  <div class="stat-label">{{ t('ut.anomalyUsers') }}</div>
                  <div class="stat-value" style="font-size:22px;color:#f56c6c">{{ anomalyData.anomaly_count.toLocaleString() }}</div>
                </div>
              </el-col>
              <el-col :span="6">
                <div class="stat-card">
                  <div class="stat-label">{{ t('ut.totalUsers') }}</div>
                  <div class="stat-value" style="font-size:22px">{{ anomalyData.total_users.toLocaleString() }}</div>
                </div>
              </el-col>
            </el-row>
            <el-table :data="anomalyData.tags.slice(0,20)" border size="small">
              <el-table-column :label="t('ut.tag')" width="140">
                <template #default="{row}">{{ tagText(row.label) }}</template>
              </el-table-column>
              <el-table-column :label="t('ut.category')" width="80">
                <template #default="{row}">{{ groupLabel(row.category) }}</template>
              </el-table-column>
              <el-table-column :label="t('ut.basePct')">
                <template #default="{row}">
                  <el-progress :percentage="Math.min(row.base_pct,100)" :stroke-width="8" :format="()=>row.base_pct+'%'" />
                </template>
              </el-table-column>
              <el-table-column :label="t('ut.anomalyPct')">
                <template #default="{row}">
                  <el-progress :percentage="Math.min(row.anom_pct,100)" :stroke-width="8" :color="'#f56c6c'" :format="()=>row.anom_pct+'%'" />
                </template>
              </el-table-column>
              <el-table-column :label="t('ut.tgi')" width="90">
                <template #default="{row}">
                  <el-tag :type="row.tgi>120?'danger':row.tgi>80?'warning':'info'" size="small">{{ row.tgi }}</el-tag>
                </template>
              </el-table-column>
            </el-table>
          </div>
        </el-tab-pane>
      </el-tabs>
    </div>

    <!-- ═══════════════════ 宽表查询 ═══════════════════ -->
    <div v-if="activeTab === 'wide'" class="card" style="border-top-left-radius:0">
      <el-row :gutter="16">
        <el-col :span="16">
          <div style="font-size:13px;font-weight:600;margin-bottom:10px">
            {{ t('ut.wideSelectHint') }}
          </div>
          <div v-for="grp in tagMeta" :key="grp.category" style="margin-bottom:12px">
            <div style="font-size:12px;color:#909399;margin-bottom:6px">{{ groupLabel(grp.category) }}</div>
            <el-checkbox-group v-model="selectedTagIds" style="display:flex;flex-wrap:wrap;gap:6px">
              <el-checkbox
                v-for="t in grp.tags" :key="t.tag_id"
                :value="t.tag_id" border size="small"
              >{{ tagLabel(t.tag_id) }}</el-checkbox>
            </el-checkbox-group>
          </div>
        </el-col>
        <el-col :span="8">
          <div style="padding:12px;background:#f5f7fa;border-radius:6px">
            <div style="font-size:13px;font-weight:600;margin-bottom:10px">{{ t('ut.selectedTags') }}</div>
            <el-tag
              v-for="tid in selectedTagIds" :key="tid" closable
              @close="selectedTagIds = selectedTagIds.filter(x => x !== tid)"
              style="margin:3px"
            >{{ tagLabel(tid) }}</el-tag>
            <div v-if="!selectedTagIds.length" style="color:#c0c4cc;font-size:12px">{{ t('ut.noSelectionAll') }}</div>
            <el-divider />
            <el-button type="primary" style="width:100%" :loading="wideLoading" @click="queryWide()">{{ t('common.query') }}</el-button>
          </div>
          <div style="margin-top:16px">
            <div style="font-size:13px;font-weight:600;margin-bottom:8px">{{ t('ut.hitTop15') }}</div>
            <div v-for="item in distribution.slice(0,15)" :key="item.col" style="display:flex;align-items:center;gap:8px;margin-bottom:4px;font-size:12px">
              <span style="width:90px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap">{{ tagText(item.label) }}</span>
              <el-progress :percentage="distPercent(item.count)" :stroke-width="10" style="flex:1" :format="() => item.count.toLocaleString()" />
            </div>
            <el-button size="small" plain @click="loadDistribution" style="margin-top:6px">{{ t('ut.refreshDistribution') }}</el-button>
          </div>
        </el-col>
      </el-row>
      <div v-if="wideResult" style="margin-top:16px">
        <div style="margin-bottom:8px;font-size:13px;color:#606266">
          {{ t('ut.wideTotalPrefix') }} <b>{{ wideResult.total.toLocaleString() }}</b> {{ t('ut.wideTotalSuffix').replace('{0}', wideResult.page) }}
        </div>
        <el-table :data="wideResult.rows" border size="small" style="width:100%">
          <el-table-column prop="customer_id" :label="t('ut.userId')" width="100" />
          <el-table-column :label="t('ut.tag')" min-width="300">
            <template #default="{row}">
              <el-tag v-for="tag in row.active_tags" :key="tag" size="small" type="success" style="margin:2px">{{ tagText(tag) }}</el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="update_time" :label="t('ut.updateTime')" width="160" />
        </el-table>
        <el-pagination
          v-if="wideResult.total > wideResult.page_size"
          style="margin-top:10px"
          layout="prev, pager, next"
          :total="wideResult.total"
          :page-size="wideResult.page_size"
          :current-page="widePage"
          @current-change="onWidePage"
        />
        <div style="font-size:12px;color:#909399;margin-top:8px">
          Doris <code>DUPLICATE KEY</code> 宽表 · TINYINT 0/1 · 向量化扫描
        </div>
      </div>
    </div>

    <!-- ═══════════════════ 行为分析 ═══════════════════ -->
    <div v-if="activeTab === 'behavior'" class="card" style="border-top-left-radius:0">
      <el-tabs v-model="behaviorTab" type="border-card">
        <el-tab-pane :label="t('ut.funnelTab')" name="funnel">
          <el-form inline style="margin-top:8px">
            <el-form-item :label="t('ut.windowSec')">
              <el-input-number v-model="funnelWindow" :min="3600" :max="2592000" :step="86400" style="width:130px" />
            </el-form-item>
            <el-form-item :label="t('ut.crowdFilter')">
              <el-select v-model="funnelFilterTags" multiple collapse-tags :placeholder="t('ut.optional')" style="width:200px">
                <el-option-group v-for="grp in tagMeta" :key="grp.category" :label="groupLabel(grp.category)">
                  <el-option v-for="tg in grp.tags" :key="tg.tag_id" :label="tagLabel(tg.tag_id)" :value="tg.tag_id" />
                </el-option-group>
              </el-select>
            </el-form-item>
            <el-form-item>
            <el-button type="primary" :loading="funnelLoading" @click="runFunnel">{{ t('ut.analyze') }}</el-button>
            </el-form-item>
          </el-form>
          <div style="margin-bottom:12px;display:flex;gap:8px;flex-wrap:wrap;align-items:center">
            <span style="font-size:13px">{{ t('ut.funnelSteps') }}:</span>
            <el-tag v-for="(s, i) in funnelSteps" :key="i" closable type="primary" @close="funnelSteps.splice(i,1)" size="small">{{ i+1 }}. {{ s }}</el-tag>
            <el-select v-model="newStep" :placeholder="t('ut.addStep')" size="small" style="width:160px" @change="addStep">
              <el-option v-for="e in eventTypes" :key="e" :label="e" :value="e" />
            </el-select>
          </div>
          <div v-if="funnelData">
            <v-chart :option="funnelOption" style="height:300px" autoresize />
            <el-table :data="funnelData.steps" border size="small" style="margin-top:10px">
              <el-table-column prop="step" :label="t('ut.step')" width="60" />
              <el-table-column prop="step_name" :label="t('ut.event')" />
              <el-table-column prop="user_count" :label="t('ut.userCount')">
                <template #default="{row}">{{ (row.user_count||0).toLocaleString() }}</template>
              </el-table-column>
              <el-table-column prop="conversion_rate" :label="t('ut.stepConversion')">
                <template #default="{row}"><el-progress :percentage="row.conversion_rate||0" :stroke-width="8" /></template>
              </el-table-column>
              <el-table-column prop="overall_rate" :label="t('ut.overallConversion')">
                <template #default="{row}"><el-tag size="small">{{ row.overall_rate }}%</el-tag></template>
              </el-table-column>
            </el-table>
          </div>
        </el-tab-pane>

        <el-tab-pane :label="t('ut.retentionTab')" name="retention">
          <el-form inline style="margin-top:8px">
            <el-form-item :label="t('ut.startEvent')">
              <el-select v-model="retCohort" style="width:130px">
                <el-option v-for="e in eventTypes" :key="e" :label="e" :value="e" />
              </el-select>
            </el-form-item>
            <el-form-item :label="t('ut.returnEvent')">
              <el-select v-model="retReturn" style="width:130px">
                <el-option v-for="e in eventTypes" :key="e" :label="e" :value="e" />
              </el-select>
            </el-form-item>
            <el-form-item>
              <el-button type="primary" :loading="retLoading" @click="runRetention">{{ t('ut.analyze') }}</el-button>
            </el-form-item>
          </el-form>
          <div v-if="retentionData" style="overflow-x:auto;margin-top:12px">
            <table class="retention-matrix">
              <thead>
                <tr>
                  <th>{{ t('ut.cohortDate') }}</th><th>{{ t('ut.initialUsers') }}</th>
                  <th v-for="d in retentionData.retention_days" :key="d">{{ t('ut.dayN').replace('{0}', d) }}</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="row in retentionData.rows" :key="row.cohort_date">
                  <td>{{ row.cohort_date }}</td>
                  <td>{{ (row.cohort_size||0).toLocaleString() }}</td>
                  <td v-for="d in retentionData.retention_days" :key="d" :style="{ background: heatColor(row[`d${d}_rate`]) }">
                    {{ row[`d${d}_rate`] }}%
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
        </el-tab-pane>

        <el-tab-pane :label="t('ut.pathTab')" name="path">
          <el-button type="primary" :loading="pathLoading" @click="runPath" style="margin-top:8px">{{ t('ut.analyzeTopPath') }}</el-button>
          <div v-if="pathData" style="margin-top:16px">
            <v-chart :option="pathOption" style="height:360px" autoresize />
          </div>
        </el-tab-pane>
      </el-tabs>
    </div>

    <!-- ═══════════════════ ETL ═══════════════════ -->
    <div v-if="activeTab === 'etl'" class="card" style="border-top-left-radius:0">
      <el-row :gutter="20">
        <el-col :span="10">
          <div class="card-title">{{ t('ut.etlTitle') }}</div>
          <p style="font-size:13px;color:#606266;line-height:1.8">
            {{ t('ut.etlDesc1') }} <code>doris_showcase.user_tag_wide</code><br/>
            {{ t('ut.etlDesc2') }} <b>BITMAP_UNION(TO_BITMAP(customer_id))</b><br/>
            {{ t('ut.etlDesc3') }} <code>doris_showcase.t_customer_tags</code>
          </p>
          <el-button type="primary" :loading="etlLoading" @click="runEtl" style="margin-top:8px">{{ t('ut.runEtl') }}</el-button>
          <div v-if="etlResult" style="margin-top:12px">
            <el-alert
              :title="etlResult.success ? t('ut.etlSuccess').replace('{0}', etlResult.tag_rows) : t('ut.etlFail').replace('{0}', etlResult.message)"
              :type="etlResult.success ? 'success' : 'error'"
              show-icon :closable="false"
            />
          </div>
        </el-col>
        <el-col :span="14">
          <div class="card-title">{{ t('ut.bitmapUserCountTitle') }}</div>
          <el-button size="small" plain @click="loadEtlOverview" style="margin-bottom:10px">{{ t('common.refresh') }}</el-button>
          <el-table :data="etlOverview" border size="small" max-height="420">
            <el-table-column prop="tag_id" label="tag_id" width="75" />
            <el-table-column prop="tag_name" :label="t('ut.colTagName')" width="170" />
            <el-table-column :label="t('ut.tag')" width="110">
              <template #default="{row}">{{ tagText(row.label) }}</template>
            </el-table-column>
            <el-table-column :label="t('ut.category')" width="80">
              <template #default="{row}">{{ groupLabel(row.category) }}</template>
            </el-table-column>
            <el-table-column prop="user_count" :label="t('ut.hitUsers')">
              <template #default="{row}">{{ (row.user_count || 0).toLocaleString() }}</template>
            </el-table-column>
          </el-table>
        </el-col>
      </el-row>
    </div>
  </div>
</template>

<script setup>
import VChart from 'vue-echarts'
import CapabilityOverview from '@/components/UserBehavior/CapabilityOverview.vue'
import { useUserTagAnalysis } from '@/composables/useUserTagAnalysis'
import { t } from '@/i18n'

const {
  activeTab, tagMeta, allCats, groupLabel, tagText, tagLabel,
  includeTagIds, excludeTagIds, bitmapLoading, crowdSize, crowdName, crowdDesc, crowdList, compareIds, compareLoading, compareResult,
  tagClass, toggleInclude, toggleExclude, computeBitmapCrowd, saveCrowd, deleteCrowd, runCompare,
  portraitTab, tgiTagIds, tgiLoading, tgiData, tgiCat, tgiCats, runTgi, tgiOption,
  crossCat1, crossCat2, crossLoading, crossData, crossMaxPct, crossColor, runCross,
  geoTagIds, geoLoading, geoData, runGeo, geoProvinceOption,
  provinces, selectedProvinces, mapLoading, targetingData, strategy, strategyPlan, toggleProvince, runTargeting, genStrategy, displayProvince,
  taTab, weightTagIds, weightLoading, weightData, anomalyLoading, anomalyData, runWeight, runAnomaly,
  selectedTagIds, wideLoading, wideResult, widePage, distribution, distPercent, queryWide, loadDistribution, onWidePage,
  etlLoading, etlResult, etlOverview, runEtl, loadEtlOverview,
  behaviorTab, eventTypes, funnelSteps, funnelWindow, funnelFilterTags, newStep, funnelLoading, funnelData, addStep, runFunnel, funnelOption,
  retCohort, retReturn, retLoading, retentionData, runRetention, heatColor, pathLoading, pathData, runPath, pathOption,
} = useUserTagAnalysis()
</script>

<style scoped>
.tag-chip {
  padding: 4px 10px;
  border-radius: 4px;
  font-size: 12px;
  cursor: pointer;
  border: 1px solid #dcdfe6;
  user-select: none;
  transition: all .15s;
}
.chip-default { background: #fff; color: #606266; }
.chip-default:hover { border-color: #409eff; color: #409eff; }
.chip-include { background: #f0f9eb; border-color: #67c23a; color: #67c23a; }
.chip-exclude { background: #fef0f0; border-color: #f56c6c; color: #f56c6c; }

.province-chip {
  padding: 4px 10px;
  border-radius: 4px;
  font-size: 12px;
  cursor: pointer;
  border: 1px solid #dcdfe6;
  user-select: none;
  transition: all .15s;
  background: #fff;
  color: #606266;
}
.province-chip:hover { border-color: #409eff; color: #409eff; }
.province-chip.selected { background: #409eff; border-color: #409eff; color: #fff; }

.cross-matrix { border-collapse: collapse; font-size: 12px; }
.cross-matrix th, .cross-matrix td { border: 1px solid #ebeef5; padding: 5px 8px; text-align: center; white-space: nowrap; }
.cross-matrix th { background: #f5f7fa; font-weight: 600; }

.retention-matrix { border-collapse: collapse; font-size: 12px; }
.retention-matrix th, .retention-matrix td { border: 1px solid #ebeef5; padding: 6px 10px; text-align: center; white-space: nowrap; }
.retention-matrix th { background: #f5f7fa; font-weight: 600; }
</style>

import React from 'react';
import DashboardLayout from '../components/layout/DashboardLayout';
import { LineChart, Line, ResponsiveContainer, CartesianGrid, XAxis, Tooltip } from 'recharts';
import { Anchor, Activity, Box, Radio, TrendingDown, TrendingUp, AlertCircle, CheckCircle2, ArrowUp, ArrowDown } from 'lucide-react';

// Mock Data
const trendData = [ { name: 'Mon', val: 0.6 }, { name: 'Tue', val: 0.65 }, { name: 'Wed', val: 0.72 }, { name: 'Thu', val: 0.8 }, { name: 'Fri', val: 0.89 }, { name: 'Sat', val: 0.94 } ];

export default function CommandCenterHome() {
  return (
    <DashboardLayout>
      <div className="max-w-[1400px] mx-auto">
        
        {/* Top Row: 2x2 KPIs on left, Wide Chart on right */}
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-6 mb-6">
          
          {/* Left Side: 2x2 Grid for KPIs */}
          <div className="col-span-1 lg:col-span-7 grid grid-cols-1 sm:grid-cols-2 gap-4">
            <KpiCard 
              title="Peak Criticality" 
              value="0.94" 
              subtitle="Bharati Station"
              trend="up"
              trendValue="12% from yesterday"
              trendState="negative"
              icon={<Activity size={18} />}
            />
            <KpiCard 
              title="Forecast MAE" 
              value="3.8%" 
              subtitle="Global Average"
              trend="down"
              trendValue="0.4% from last week"
              trendState="positive"
              icon={<TrendingDown size={18} />}
            />
            <KpiCard 
              title="Cargo Capacity Util." 
              value="92%" 
              subtitle="Planned Resupply"
              trend="up"
              trendValue="Optimized via Knapsack"
              trendState="positive"
              icon={<Box size={18} />}
            />
            <KpiCard 
              title="Active Escalations" 
              value="2" 
              subtitle="Burst Channel"
              trend="up"
              trendValue="Immediate Action Req."
              trendState="negative"
              icon={<AlertCircle size={18} />}
            />
          </div>

          {/* Right Side: Wide Chart */}
          <div className="col-span-1 lg:col-span-5 bg-white rounded-lg p-4 sm:p-6 shadow-sm border border-slate-200 flex flex-col">
            <div className="flex flex-col sm:flex-row justify-between sm:items-start gap-4 mb-6 border-b border-slate-100 pb-4">
              <div>
                <h3 className="text-base sm:text-lg font-bold text-slate-900">Criticality Trajectory</h3>
                <div className="text-xl sm:text-2xl font-bold text-slate-900 tracking-tight mt-1">
                  0.94 
                  <span className="text-[10px] font-bold text-rose-700 ml-2 bg-rose-50 border border-rose-200 px-2 py-0.5 rounded tracking-wider align-middle">
                    High Risk
                  </span>
                </div>
              </div>
              <select className="w-full sm:w-auto text-xs font-medium bg-slate-50 border border-slate-200 rounded-md px-3 py-1.5 text-slate-700 outline-none focus:ring-1 focus:ring-sky-500">
                <option>This Week</option>
                <option>Last 30 Days</option>
              </select>
            </div>
            <div className="flex-1 w-full min-h-[150px]">
              <ResponsiveContainer width="100%" height="100%">
                <LineChart data={trendData}>
                  <CartesianGrid strokeDasharray="3 3" vertical={false} stroke="#E2E8F0" />
                  <XAxis dataKey="name" axisLine={false} tickLine={false} tick={{fontSize: 10, fill: '#64748B', fontWeight: 500}} dy={10} />
                  <Tooltip contentStyle={{ borderRadius: '6px', border: '1px solid #E2E8F0', boxShadow: '0 1px 2px 0 rgb(0 0 0 / 0.05)' }} />
                  <Line type="monotone" dataKey="val" stroke="#0284C7" strokeWidth={2} dot={{r: 4, fill: '#0284C7', strokeWidth: 2, stroke: '#fff'}} activeDot={{r: 6}} />
                </LineChart>
              </ResponsiveContainer>
            </div>
          </div>
        </div>

        {/* Bottom Row: Active Plans Table + Dark Status Card */}
        <div className="grid grid-cols-1 lg:grid-cols-12 gap-6">
          
          {/* Main Table Area */}
          <div className="col-span-1 lg:col-span-8 bg-white rounded-lg p-4 sm:p-6 shadow-sm border border-slate-200">
             <div className="flex justify-between items-center mb-6">
                <h3 className="text-base sm:text-lg font-bold text-slate-900 tracking-tight">Active Resupply Plans (Knapsack Optimized)</h3>
                <button className="text-sm text-blue-600 font-medium hover:text-sky-700 transition-colors whitespace-nowrap ml-4">View All</button>
             </div>
             
             <div className="overflow-x-auto">
               <table className="w-full text-left border-collapse min-w-[600px]">
                <thead>
                  <tr className="text-[12px] font-semibold text-slate-500 border-b border-slate-200 tracking-wider bg-slate-50">
                    <th className="py-3 px-4 font-semibold rounded-tl-md">Plan ID</th>
                    <th className="py-3 px-4 font-semibold">Target Station</th>
                    <th className="py-3 px-4 font-semibold">Fulfillment</th>
                    <th className="py-3 px-4 font-semibold">Residual Risk</th>
                    <th className="py-3 px-4 font-semibold text-right rounded-tr-md">Status</th>
                  </tr>
                </thead>
                <tbody className="text-sm text-slate-700">
                  <TableRow id="OPT-2026-BHA-01" target="Bharati Station" fulfillment="80%" risk="High" status="Planned" />
                  <TableRow id="OPT-2026-MAI-04" target="Maitri Station" fulfillment="100%" risk="Low" status="In Transit" />
                  <TableRow id="OPT-2026-BHA-02" target="Bharati Station" fulfillment="92%" risk="Med" status="Delivered" />
                </tbody>
              </table>
            </div>
          </div>

          {/* Tactical Status Card */}
          <div className="col-span-1 lg:col-span-4 bg-slate-900 border border-slate-800 rounded-lg p-6 text-white shadow-sm flex flex-col justify-between">
            <div>
              <div className="flex items-center gap-2 text-slate-400 mb-4 text-sm font-medium tracking-wider">
                <Radio size={14} className="text-sky-500" /> SATCOM Delta Sync
              </div>
              <div className="text-3xl sm:text-4xl font-bold text-white mb-2 tracking-tight">
                99.8% 
                <span className="text-[12px] font-bold bg-emerald-500/10 text-emerald-400 border border-emerald-500/20 px-2 py-1 rounded-sm ml-3 align-middle tracking-widest">
                  Online
                </span>
              </div>
              <p className="text-xs text-slate-400 font-medium">Packet success rate across all field facilities.</p>
            </div>
            
            <div className="mt-8 bg-slate-800/50 border border-slate-700/50 rounded-md p-4">
              <div className="flex flex-col sm:flex-row sm:justify-between sm:items-center gap-2 text-sm font-medium tracking-wider">
                <span className="text-slate-400">Next Sync Window</span>
                <span className="text-white font-mono">14:00 UTC</span>
              </div>
              <div className="w-full bg-slate-950 rounded-sm h-1.5 mt-3 border border-slate-800">
                <div className="bg-sky-500 h-full rounded-sm w-[70%]"></div>
              </div>
            </div>
          </div>

        </div>
      </div>
    </DashboardLayout>
  );
}

// Sub-components
function KpiCard({ title, value, subtitle, trend, trendValue, trendState, icon }) {
  const isUp = trend === 'up';
  const trendColor = trendState === 'positive' ? 'text-emerald-600' : 'text-rose-600';
  
  return (
    <div className="bg-white p-4 sm:p-5 rounded-lg border border-slate-200 shadow-sm flex flex-col justify-between h-full min-h-[128px]">
      <div className="flex justify-between items-start mb-2">
        <div className="p-2 border border-slate-200 rounded-md bg-slate-50 text-slate-600">
          {icon}
        </div>
        <div className="text-right">
           <h3 className="text-[13px] sm:text-[14px] font-semibold text-slate-500">{title}</h3>
           <p className="text-[11px] sm:text-[12px] text-slate-400 font-medium">{subtitle}</p>
        </div>
      </div>
      <div>
        <span className="text-xl sm:text-2xl font-bold text-slate-900 tracking-tight">{value}</span>
        <div className="flex items-center gap-0.5 font-medium tracking-wider mt-1">
          <span className={`font-bold text ${trendColor}`}>
             {isUp ? <ArrowUp size='14' strokeWidth='2' /> : <ArrowDown size='14' />}
          </span>
          <span className="text-slate-500 text-[11px] sm:text-[12px]">{trendValue}</span>
        </div>
      </div>
    </div>
  );
}

function TableRow({ id, target, fulfillment, risk, status }) {
  const getRiskIcon = (level) => {
    if (level === 'Low') return <CheckCircle2 size={14} className="text-emerald-600" />;
    if (level === 'Med') return <AlertCircle size={14} className="text-amber-500" />;
    return <AlertCircle size={14} className="text-rose-600" />;
  };

  const getStatusColor = (s) => {
    if (s === 'Planned') return 'text-slate-700 border-slate-200';
    if (s === 'In Transit') return 'text-sky-700 border-sky-200';
    return 'text-emerald-700 border-emerald-200';
  };

  return (
    <tr className="border-b border-slate-100 hover:bg-slate-50 transition-colors">
      <td className="py-3 px-4">
        <div className="font-mono text-xs font-semibold text-slate-800">{id}</div>
      </td>
      <td className="py-3 px-4 text-sm font-medium text-slate-600">{target}</td>
      <td className="py-3 px-4 text-sm font-bold text-slate-900">{fulfillment}</td>
      <td className="py-3 px-4">
        <div className="flex items-center gap-1.5 text-xs text-slate-600 font-medium">
          {getRiskIcon(risk)} <span className="uppercase text-[12px] font-bold">{risk}</span>
        </div>
      </td>
      <td className="py-3 px-4 text-right">
        <span className={`px-2.5 py-1 rounded text-[10px] font-semibold border ${getStatusColor(status)}`}>
          {status}
        </span>
      </td>
    </tr>
  );
}
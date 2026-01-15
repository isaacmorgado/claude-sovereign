'use client';

import React from 'react';
import { DollarSign, Clock, AlertTriangle, BookOpen, CheckCircle, ChevronDown, ChevronUp } from 'lucide-react';

// ============================================
// TYPES
// ============================================

interface TriggerReason {
  metric: string;
  value: number;
  threshold: number;
  operator?: '<' | '>';
}

interface PlanContent {
  description: string;
  cost_min: number;
  cost_max: number;
  time_min: string;
  time_max: string;
  risks: string;
  citations: string[];
  tags?: string[];
}

export interface Plan {
  id: string;
  title: string;
  content: PlanContent;
  trigger_reason?: TriggerReason[];
}

interface PlanActionCardProps {
  plan: Plan;
  defaultExpanded?: boolean;
}

// ============================================
// COMPONENT
// ============================================

export const PlanActionCard: React.FC<PlanActionCardProps> = ({ plan, defaultExpanded = false }) => {
  const [isExpanded, setIsExpanded] = React.useState(defaultExpanded);

  // Format cost display
  const formatCost = () => {
    const { cost_min, cost_max } = plan.content;
    if (cost_min === 0 && cost_max === 0) {
      return 'Free';
    }
    if (cost_min === cost_max) {
      return `$${cost_min.toLocaleString()}`;
    }
    return `$${cost_min.toLocaleString()} - $${cost_max.toLocaleString()}`;
  };

  // Format timeline display
  const formatTimeline = () => {
    const { time_min, time_max } = plan.content;
    if (time_min === time_max || !time_max) {
      return time_min;
    }
    return `${time_min} - ${time_max}`;
  };

  return (
    <div className="bg-white rounded-lg border border-gray-200 hover:border-gray-300 transition-all duration-200 shadow-sm">
      <div className="p-5">
        <div className="flex justify-between items-start gap-4">
          <div className="flex-1">
            {/* Header */}
            <div className="flex items-center gap-3 mb-2">
              <h3 className="text-base font-semibold text-gray-900">{plan.title}</h3>
              <div className="flex gap-2">
                {/* Dynamic Tags */}
                {plan.content.tags?.map((tag) => (
                  <span
                    key={tag}
                    className="text-[10px] uppercase font-semibold px-2 py-0.5 rounded-md bg-blue-50 text-blue-700 border border-blue-100"
                  >
                    {tag}
                  </span>
                ))}
              </div>
            </div>

            <p className="text-sm text-gray-500 leading-relaxed mb-4">
              {plan.content.description}
            </p>

            {/* Quick Stats Row */}
            <div className="flex items-center gap-6 text-xs text-gray-500">
              <div className="flex items-center gap-1.5" title="Estimated Cost">
                <DollarSign className="w-3.5 h-3.5 text-gray-400" />
                <span className="font-medium">{formatCost()}</span>
              </div>
              <div className="flex items-center gap-1.5" title="Timeline">
                <Clock className="w-3.5 h-3.5 text-gray-400" />
                <span className="font-medium">{formatTimeline()}</span>
              </div>
            </div>
          </div>

          {/* Toggle Button */}
          <button
            onClick={() => setIsExpanded(!isExpanded)}
            className="p-1.5 rounded-md hover:bg-gray-100 text-gray-400 transition-colors"
            aria-label={isExpanded ? 'Collapse details' : 'Expand details'}
          >
            {isExpanded ? <ChevronUp className="w-5 h-5" /> : <ChevronDown className="w-5 h-5" />}
          </button>
        </div>
      </div>

      {/* Expandable Section (The "Why" and "Risks") */}
      {isExpanded && (
        <div className="bg-gray-50/50 border-t border-gray-100 p-5 space-y-4">

          {/* Why this was recommended (Trigger Rules) */}
          {plan.trigger_reason && plan.trigger_reason.length > 0 && (
            <div>
              <h4 className="flex items-center gap-2 text-xs font-semibold text-gray-900 uppercase tracking-wide mb-2">
                <CheckCircle className="w-3.5 h-3.5 text-emerald-500" />
                Why Recommended
              </h4>
              <div className="flex flex-wrap gap-2">
                {plan.trigger_reason.map((reason, i) => (
                  <div
                    key={i}
                    className="inline-flex items-center gap-1.5 px-2.5 py-1 bg-white border border-gray-200 rounded-md text-xs font-medium text-gray-700 shadow-sm"
                  >
                    <span>{reason.metric}: {reason.value.toFixed(1)}</span>
                    <span className="text-gray-400 text-[10px]">
                      ({reason.operator === '>' ? 'above' : 'below'} {reason.threshold})
                    </span>
                  </div>
                ))}
              </div>
            </div>
          )}

          {/* Risks */}
          {plan.content.risks && (
            <div>
              <h4 className="flex items-center gap-2 text-xs font-semibold text-gray-900 uppercase tracking-wide mb-2">
                <AlertTriangle className="w-3.5 h-3.5 text-amber-500" />
                Risks & Considerations
              </h4>
              <div className="bg-amber-50/50 p-3 rounded-lg border border-amber-100 text-xs text-amber-900/80 leading-relaxed">
                {plan.content.risks}
              </div>
            </div>
          )}

          {/* Research */}
          {plan.content.citations && plan.content.citations.length > 0 && (
            <div>
              <h4 className="flex items-center gap-2 text-xs font-semibold text-gray-900 uppercase tracking-wide mb-2">
                <BookOpen className="w-3.5 h-3.5 text-blue-500" />
                Research
              </h4>
              <div className="text-xs text-blue-800 bg-blue-50/50 p-3 rounded-lg border border-blue-100">
                {plan.content.citations.join(", ")}
              </div>
            </div>
          )}

        </div>
      )}
    </div>
  );
};

export default PlanActionCard;

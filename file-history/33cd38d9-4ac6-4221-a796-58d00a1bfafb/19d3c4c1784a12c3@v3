'use client';

import { useMemo } from 'react';
import { motion } from 'framer-motion';
import {
  TrendingUp,
  TrendingDown,
  Minus,
  Star,
  Target,
  Activity,
  Sparkles,
} from 'lucide-react';
import { LandmarkPoint } from '@/lib/landmarks';
import {
  comprehensiveFrontAnalysis,
  comprehensiveSideAnalysis,
  generateMeasurementBellCurve,
  BellCurveData,
} from '@/lib/scoring';
import {
  BellCurveChart,
  HarmonyScoreDisplay,
} from './BellCurveChart';

interface ResultsDashboardProps {
  frontLandmarks: LandmarkPoint[];
  sideLandmarks: LandmarkPoint[];
  gender: 'male' | 'female';
}

interface MeasurementCardProps {
  title: string;
  value: number;
  unit: string;
  score: number;
  idealRange: { min: number; max: number };
  description: string;
  rating: 'excellent' | 'good' | 'average' | 'below_average';
}

function MeasurementCard({
  title,
  value,
  unit,
  score,
  idealRange,
  description,
  rating,
}: MeasurementCardProps) {
  const ratingConfig = {
    excellent: { color: '#10b981', label: 'Excellent', icon: Star },
    good: { color: '#0891b2', label: 'Good', icon: TrendingUp },
    average: { color: '#eab308', label: 'Average', icon: Minus },
    below_average: { color: '#f97316', label: 'Below Avg', icon: TrendingDown },
  };

  const config = ratingConfig[rating];
  const Icon = config.icon;

  const isInRange = value >= idealRange.min && value <= idealRange.max;

  return (
    <motion.div
      initial={{ opacity: 0, y: 10 }}
      animate={{ opacity: 1, y: 0 }}
      className="bg-black rounded-xl border border-neutral-800 p-4 hover:border-neutral-700 transition-colors"
    >
      <div className="flex items-start justify-between mb-3">
        <div>
          <h4 className="text-sm font-semibold text-white">{title}</h4>
          <p className="text-xs text-neutral-500 mt-0.5">{description}</p>
        </div>
        <div
          className="flex items-center gap-1 px-2 py-1 rounded-full text-xs font-medium"
          style={{
            backgroundColor: `${config.color}15`,
            color: config.color,
          }}
        >
          <Icon className="w-3 h-3" />
          {config.label}
        </div>
      </div>

      <div className="flex items-end justify-between">
        <div>
          <span className="text-2xl font-bold text-white">
            {typeof value === 'number' ? value.toFixed(2) : value}
          </span>
          <span className="text-sm text-neutral-500 ml-1">{unit}</span>
        </div>
        <div className="text-right">
          <div className="text-xs text-neutral-500 mb-1">
            Ideal: {idealRange.min.toFixed(1)} - {idealRange.max.toFixed(1)}
          </div>
          <div
            className="text-xs font-medium"
            style={{ color: isInRange ? '#10b981' : '#f97316' }}
          >
            {isInRange ? 'In Range' : value < idealRange.min ? 'Below Ideal' : 'Above Ideal'}
          </div>
        </div>
      </div>

      {/* Score bar */}
      <div className="mt-3 h-1.5 bg-neutral-800 rounded-full overflow-hidden">
        <motion.div
          className="h-full rounded-full"
          style={{ backgroundColor: config.color }}
          initial={{ width: 0 }}
          animate={{ width: `${Math.min(score, 100)}%` }}
          transition={{ duration: 0.8 }}
        />
      </div>
      <div className="mt-1 text-right">
        <span className="text-xs font-medium" style={{ color: config.color }}>
          Score: {score.toFixed(0)}/100
        </span>
      </div>
    </motion.div>
  );
}

interface StrengthWeaknessProps {
  strengths: Array<{ name: string; score: number; description: string }>;
  improvements: Array<{ name: string; score: number; suggestion: string }>;
}

function StrengthsWeaknesses({ strengths, improvements }: StrengthWeaknessProps) {
  return (
    <div className="grid md:grid-cols-2 gap-6">
      {/* Strengths */}
      <motion.div
        initial={{ opacity: 0, x: -20 }}
        animate={{ opacity: 1, x: 0 }}
        className="bg-black rounded-xl border border-neutral-800 p-5"
      >
        <div className="flex items-center gap-2 mb-4">
          <div className="p-2 rounded-lg bg-green-500/20">
            <Sparkles className="w-5 h-5 text-green-400" />
          </div>
          <h3 className="text-lg font-semibold text-white">Your Strengths</h3>
        </div>
        <div className="space-y-3">
          {strengths.map((strength, index) => (
            <div
              key={index}
              className="flex items-start gap-3 p-3 rounded-lg bg-green-500/10 border border-green-500/20"
            >
              <div className="w-8 h-8 rounded-full bg-green-500/20 flex items-center justify-center flex-shrink-0">
                <span className="text-sm font-bold text-green-400">
                  {strength.score.toFixed(0)}
                </span>
              </div>
              <div>
                <p className="text-sm font-medium text-white">{strength.name}</p>
                <p className="text-xs text-neutral-400 mt-0.5">
                  {strength.description}
                </p>
              </div>
            </div>
          ))}
        </div>
      </motion.div>

      {/* Areas for Improvement */}
      <motion.div
        initial={{ opacity: 0, x: 20 }}
        animate={{ opacity: 1, x: 0 }}
        className="bg-black rounded-xl border border-neutral-800 p-5"
      >
        <div className="flex items-center gap-2 mb-4">
          <div className="p-2 rounded-lg bg-amber-500/20">
            <Target className="w-5 h-5 text-amber-400" />
          </div>
          <h3 className="text-lg font-semibold text-white">Areas for Improvement</h3>
        </div>
        <div className="space-y-3">
          {improvements.map((item, index) => (
            <div
              key={index}
              className="flex items-start gap-3 p-3 rounded-lg bg-amber-500/10 border border-amber-500/20"
            >
              <div className="w-8 h-8 rounded-full bg-amber-500/20 flex items-center justify-center flex-shrink-0">
                <span className="text-sm font-bold text-amber-400">
                  {item.score.toFixed(0)}
                </span>
              </div>
              <div>
                <p className="text-sm font-medium text-white">{item.name}</p>
                <p className="text-xs text-neutral-400 mt-0.5">{item.suggestion}</p>
              </div>
            </div>
          ))}
        </div>
      </motion.div>
    </div>
  );
}

export function ResultsDashboard({
  frontLandmarks,
  sideLandmarks,
  gender,
}: ResultsDashboardProps) {
  // Calculate all analyses
  const frontAnalysis = useMemo(() => {
    if (frontLandmarks.length === 0) return null;
    return comprehensiveFrontAnalysis(frontLandmarks, gender);
  }, [frontLandmarks, gender]);

  const sideAnalysis = useMemo(() => {
    if (sideLandmarks.length === 0) return null;
    return comprehensiveSideAnalysis(sideLandmarks, gender);
  }, [sideLandmarks, gender]);

  // Calculate overall harmony score
  const harmonyScore = useMemo(() => {
    const scores: number[] = [];
    if (frontAnalysis) scores.push(frontAnalysis.harmonyScore);
    if (sideAnalysis) scores.push(sideAnalysis.harmonyScore);
    return scores.length > 0 ? scores.reduce((a, b) => a + b, 0) / scores.length : 0;
  }, [frontAnalysis, sideAnalysis]);

  // Collect all individual scores
  const allScores = useMemo(() => {
    const scores: Record<string, number> = {};

    if (frontAnalysis) {
      if (frontAnalysis.fwhr) scores.fwhr = frontAnalysis.fwhr.score;
      if (frontAnalysis.leftCanthalTilt) scores.canthalTilt = frontAnalysis.leftCanthalTilt.score;
      if (frontAnalysis.facialThirds) scores.facialThirds = frontAnalysis.facialThirds.overall.score;
      if (frontAnalysis.nasalIndex) scores.nasalIndex = frontAnalysis.nasalIndex.score;
      if (frontAnalysis.mouthNoseRatio) scores.mouthNoseRatio = frontAnalysis.mouthNoseRatio.score;
      if (frontAnalysis.jawRatio) scores.jawRatio = frontAnalysis.jawRatio.score;
    }

    if (sideAnalysis) {
      if (sideAnalysis.gonialAngle) scores.gonialAngle = sideAnalysis.gonialAngle.score;
      if (sideAnalysis.nasolabialAngle) scores.nasolabialAngle = sideAnalysis.nasolabialAngle.score;
      if (sideAnalysis.eLine) scores.eLine = sideAnalysis.eLine.combined.score;
      if (sideAnalysis.mentolabialAngle) scores.mentolabialAngle = sideAnalysis.mentolabialAngle.score;
      if (sideAnalysis.nasofrontalAngle) scores.nasofrontalAngle = sideAnalysis.nasofrontalAngle.score;
    }

    return scores;
  }, [frontAnalysis, sideAnalysis]);

  // Generate bell curve data for key measurements
  const bellCurveData = useMemo(() => {
    const data: Array<{ key: string; title: string; data: BellCurveData; unit?: string }> = [];

    if (frontAnalysis?.fwhr) {
      const bellData = generateMeasurementBellCurve('fwhr', frontAnalysis.fwhr.value, gender);
      if (bellData) {
        data.push({ key: 'fwhr', title: 'Face Width-to-Height Ratio', data: bellData });
      }
    }

    if (frontAnalysis?.leftCanthalTilt) {
      const bellData = generateMeasurementBellCurve('canthalTilt', frontAnalysis.leftCanthalTilt.value, gender);
      if (bellData) {
        data.push({ key: 'canthalTilt', title: 'Canthal Tilt', data: bellData, unit: '°' });
      }
    }

    return data;
  }, [frontAnalysis, gender]);

  // Determine strengths and weaknesses
  const { strengths, improvements } = useMemo(() => {
    const allResults: Array<{ name: string; score: number; description: string; suggestion: string }> = [];

    const measurementDescriptions: Record<string, { name: string; desc: string; suggestion: string }> = {
      fwhr: {
        name: 'Facial Width-to-Height Ratio',
        desc: 'Your face has good proportional width relative to height',
        suggestion: 'Consider facial exercises to enhance jaw definition'
      },
      canthalTilt: {
        name: 'Eye Canthal Tilt',
        desc: 'Your eyes have an attractive upward tilt',
        suggestion: 'Eye-lifting treatments or makeup techniques can enhance tilt'
      },
      facialThirds: {
        name: 'Facial Thirds Balance',
        desc: 'Your face has well-balanced vertical proportions',
        suggestion: 'Hairstyle adjustments can help balance facial thirds'
      },
      nasalIndex: {
        name: 'Nasal Proportions',
        desc: 'Your nose width-to-height ratio is harmonious',
        suggestion: 'Contouring can create the illusion of different proportions'
      },
      gonialAngle: {
        name: 'Jaw Angle',
        desc: 'Your jaw has an attractive angular definition',
        suggestion: 'Jaw exercises or mewing can help define the gonial angle'
      },
      nasolabialAngle: {
        name: 'Nose-Lip Angle',
        desc: 'The angle between your nose and lip is well-balanced',
        suggestion: 'Nose profile can be enhanced with non-surgical treatments'
      },
      eLine: {
        name: 'E-Line Profile',
        desc: 'Your lip position relative to nose-chin line is ideal',
        suggestion: 'Lip fillers or chin augmentation can improve E-line balance'
      },
      mouthNoseRatio: {
        name: 'Mouth-to-Nose Ratio',
        desc: 'Your mouth width is proportional to your nose',
        suggestion: 'Lip treatments can adjust the perceived ratio'
      },
      jawRatio: {
        name: 'Jaw-to-Face Width',
        desc: 'Your jaw width is proportional to your face',
        suggestion: 'Jaw slimming or enhancement can adjust this ratio'
      },
    };

    Object.entries(allScores).forEach(([key, score]) => {
      const info = measurementDescriptions[key];
      if (info) {
        allResults.push({
          name: info.name,
          score,
          description: info.desc,
          suggestion: info.suggestion,
        });
      }
    });

    // Sort by score
    allResults.sort((a, b) => b.score - a.score);

    // Top 3 are strengths, bottom 3 are improvements
    const strengths = allResults.slice(0, 3).map(r => ({
      name: r.name,
      score: r.score,
      description: r.description,
    }));

    const improvements = allResults.slice(-3).reverse().map(r => ({
      name: r.name,
      score: r.score,
      suggestion: r.suggestion,
    }));

    return { strengths, improvements };
  }, [allScores]);

  if (!frontAnalysis && !sideAnalysis) {
    return (
      <div className="text-center py-12">
        <Activity className="w-12 h-12 text-neutral-600 mx-auto mb-4" />
        <p className="text-neutral-400">No analysis data available</p>
      </div>
    );
  }

  return (
    <div className="space-y-8">
      {/* Hero Score Section */}
      <motion.div
        initial={{ opacity: 0, y: 20 }}
        animate={{ opacity: 1, y: 0 }}
        className="text-center"
      >
        <h2 className="text-2xl font-bold text-white mb-2">Your Analysis Results</h2>
        <p className="text-neutral-400 mb-8">
          Based on {frontLandmarks.length + sideLandmarks.length} facial landmarks
        </p>

        {/* Main Harmony Score Display */}
        <HarmonyScoreDisplay
          harmonyScore={harmonyScore}
          individualScores={allScores}
        />
      </motion.div>

      {/* Strengths & Weaknesses */}
      {strengths.length > 0 && improvements.length > 0 && (
        <StrengthsWeaknesses strengths={strengths} improvements={improvements} />
      )}

      {/* Front Profile Measurements */}
      {frontAnalysis && (
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
        >
          <div className="flex items-center gap-2 mb-4">
            <h3 className="text-lg font-semibold text-white">Front Profile Analysis</h3>
            <span className="px-2 py-0.5 rounded-full bg-neutral-800 text-neutral-300 text-xs">
              {frontLandmarks.length} landmarks
            </span>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
            {frontAnalysis.fwhr && (
              <MeasurementCard
                title="FWHR"
                value={frontAnalysis.fwhr.value}
                unit="ratio"
                score={frontAnalysis.fwhr.score}
                idealRange={frontAnalysis.fwhr.idealRange}
                description="Facial Width-to-Height Ratio"
                rating={frontAnalysis.fwhr.rating}
              />
            )}

            {frontAnalysis.facialThirds && (
              <MeasurementCard
                title="Facial Thirds"
                value={frontAnalysis.facialThirds.overall.value}
                unit="% deviation"
                score={frontAnalysis.facialThirds.overall.score}
                idealRange={frontAnalysis.facialThirds.overall.idealRange}
                description="Vertical face proportion balance"
                rating={frontAnalysis.facialThirds.overall.rating}
              />
            )}

            {frontAnalysis.leftCanthalTilt && (
              <MeasurementCard
                title="Canthal Tilt"
                value={frontAnalysis.leftCanthalTilt.value}
                unit="°"
                score={frontAnalysis.leftCanthalTilt.score}
                idealRange={frontAnalysis.leftCanthalTilt.idealRange}
                description="Eye angle from inner to outer corner"
                rating={frontAnalysis.leftCanthalTilt.rating}
              />
            )}

            {frontAnalysis.nasalIndex && (
              <MeasurementCard
                title="Nasal Index"
                value={frontAnalysis.nasalIndex.value}
                unit="%"
                score={frontAnalysis.nasalIndex.score}
                idealRange={frontAnalysis.nasalIndex.idealRange}
                description="Nose width to height ratio"
                rating={frontAnalysis.nasalIndex.rating}
              />
            )}

            {frontAnalysis.mouthNoseRatio && (
              <MeasurementCard
                title="Mouth-Nose Ratio"
                value={frontAnalysis.mouthNoseRatio.value}
                unit="ratio"
                score={frontAnalysis.mouthNoseRatio.score}
                idealRange={frontAnalysis.mouthNoseRatio.idealRange}
                description="Mouth width relative to nose"
                rating={frontAnalysis.mouthNoseRatio.rating}
              />
            )}

            {frontAnalysis.jawRatio && (
              <MeasurementCard
                title="Jaw-Face Ratio"
                value={frontAnalysis.jawRatio.value}
                unit="ratio"
                score={frontAnalysis.jawRatio.score}
                idealRange={frontAnalysis.jawRatio.idealRange}
                description="Jaw width to face width"
                rating={frontAnalysis.jawRatio.rating}
              />
            )}
          </div>
        </motion.div>
      )}

      {/* Side Profile Measurements */}
      {sideAnalysis && (
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
        >
          <div className="flex items-center gap-2 mb-4">
            <h3 className="text-lg font-semibold text-white">Side Profile Analysis</h3>
            <span className="px-2 py-0.5 rounded-full bg-neutral-800 text-neutral-300 text-xs">
              {sideLandmarks.length} landmarks
            </span>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
            {sideAnalysis.gonialAngle && (
              <MeasurementCard
                title="Gonial Angle"
                value={sideAnalysis.gonialAngle.value}
                unit="°"
                score={sideAnalysis.gonialAngle.score}
                idealRange={sideAnalysis.gonialAngle.idealRange}
                description="Jaw angle measurement"
                rating={sideAnalysis.gonialAngle.rating}
              />
            )}

            {sideAnalysis.nasolabialAngle && (
              <MeasurementCard
                title="Nasolabial Angle"
                value={sideAnalysis.nasolabialAngle.value}
                unit="°"
                score={sideAnalysis.nasolabialAngle.score}
                idealRange={sideAnalysis.nasolabialAngle.idealRange}
                description="Nose to upper lip angle"
                rating={sideAnalysis.nasolabialAngle.rating}
              />
            )}

            {sideAnalysis.eLine && (
              <MeasurementCard
                title="E-Line (Ricketts)"
                value={sideAnalysis.eLine.combined.value}
                unit="mm"
                score={sideAnalysis.eLine.combined.score}
                idealRange={sideAnalysis.eLine.combined.idealRange}
                description="Lip position relative to nose-chin line"
                rating={sideAnalysis.eLine.combined.rating}
              />
            )}

            {sideAnalysis.mentolabialAngle && (
              <MeasurementCard
                title="Mentolabial Angle"
                value={sideAnalysis.mentolabialAngle.value}
                unit="°"
                score={sideAnalysis.mentolabialAngle.score}
                idealRange={sideAnalysis.mentolabialAngle.idealRange}
                description="Chin-lip fold depth"
                rating={sideAnalysis.mentolabialAngle.rating}
              />
            )}

            {sideAnalysis.nasofrontalAngle && (
              <MeasurementCard
                title="Nasofrontal Angle"
                value={sideAnalysis.nasofrontalAngle.value}
                unit="°"
                score={sideAnalysis.nasofrontalAngle.score}
                idealRange={sideAnalysis.nasofrontalAngle.idealRange}
                description="Forehead to nose bridge angle"
                rating={sideAnalysis.nasofrontalAngle.rating}
              />
            )}
          </div>
        </motion.div>
      )}

      {/* Bell Curve Charts */}
      {bellCurveData.length > 0 && (
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
        >
          <h3 className="text-lg font-semibold text-white mb-4">
            Population Comparison
          </h3>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            {bellCurveData.map((item) => (
              <BellCurveChart
                key={item.key}
                data={item.data}
                title={item.title}
                unit={item.unit}
                height={180}
              />
            ))}
          </div>
        </motion.div>
      )}

      {/* Detailed Facial Thirds Breakdown */}
      {frontAnalysis?.facialThirds && (
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          className="bg-black rounded-xl border border-neutral-800 p-5"
        >
          <h3 className="text-lg font-semibold text-white mb-4">
            Facial Thirds Breakdown
          </h3>
          <div className="grid grid-cols-3 gap-4">
            <div className="text-center">
              <div className="h-20 bg-gradient-to-b from-neutral-700 to-transparent rounded-t-lg mb-2 flex items-end justify-center pb-2">
                <span className="text-2xl font-bold text-white">
                  {frontAnalysis.facialThirds.upper.value.toFixed(1)}%
                </span>
              </div>
              <p className="text-xs text-neutral-400">Upper Third</p>
              <p className="text-xs text-neutral-500">Hairline to Brow</p>
            </div>
            <div className="text-center">
              <div className="h-20 bg-gradient-to-b from-[#00f3ff]/30 to-transparent rounded-t-lg mb-2 flex items-end justify-center pb-2">
                <span className="text-2xl font-bold text-white">
                  {frontAnalysis.facialThirds.middle.value.toFixed(1)}%
                </span>
              </div>
              <p className="text-xs text-neutral-400">Middle Third</p>
              <p className="text-xs text-[#00f3ff]">Brow to Nose Base</p>
            </div>
            <div className="text-center">
              <div className="h-20 bg-gradient-to-b from-green-500/30 to-transparent rounded-t-lg mb-2 flex items-end justify-center pb-2">
                <span className="text-2xl font-bold text-white">
                  {frontAnalysis.facialThirds.lower.value.toFixed(1)}%
                </span>
              </div>
              <p className="text-xs text-neutral-400">Lower Third</p>
              <p className="text-xs text-green-400">Nose Base to Chin</p>
            </div>
          </div>
          <div className="mt-4 text-center">
            <p className="text-sm text-neutral-400">
              Ideal distribution: 33.3% each • Your balance score:{' '}
              <span className="text-white font-medium">
                {frontAnalysis.facialThirds.overall.score.toFixed(0)}/100
              </span>
            </p>
          </div>
        </motion.div>
      )}
    </div>
  );
}

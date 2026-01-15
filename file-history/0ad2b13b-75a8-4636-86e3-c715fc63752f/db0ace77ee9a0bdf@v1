/**
 * Export Report Functionality
 * Export analysis results as PDF or Image
 */

import html2canvas from 'html2canvas';
import { jsPDF } from 'jspdf';

export interface ExportOptions {
  filename?: string;
  scale?: number;
  backgroundColor?: string;
}

/**
 * Export an element as a PNG image
 */
export async function exportToImage(
  elementId: string,
  options: ExportOptions = {}
): Promise<{ success: boolean; error?: string }> {
  const {
    filename = 'looksmaxx-results',
    scale = 2,
    backgroundColor = '#0a0a0a',
  } = options;

  const element = document.getElementById(elementId);
  if (!element) {
    return { success: false, error: 'Element not found' };
  }

  try {
    const canvas = await html2canvas(element, {
      scale,
      backgroundColor,
      useCORS: true,
      allowTaint: true,
      logging: false,
    });

    const link = document.createElement('a');
    link.href = canvas.toDataURL('image/png');
    link.download = `${filename}.png`;
    link.click();

    return { success: true };
  } catch (error) {
    return {
      success: false,
      error: error instanceof Error ? error.message : 'Failed to export image'
    };
  }
}

/**
 * Export an element as a PDF document
 */
export async function exportToPDF(
  elementId: string,
  options: ExportOptions = {}
): Promise<{ success: boolean; error?: string }> {
  const {
    filename = 'looksmaxx-results',
    scale = 2,
    backgroundColor = '#0a0a0a',
  } = options;

  const element = document.getElementById(elementId);
  if (!element) {
    return { success: false, error: 'Element not found' };
  }

  try {
    const canvas = await html2canvas(element, {
      scale,
      backgroundColor,
      useCORS: true,
      allowTaint: true,
      logging: false,
    });

    const imgData = canvas.toDataURL('image/png');
    const imgWidth = canvas.width;
    const imgHeight = canvas.height;

    // Determine orientation based on aspect ratio
    const orientation = imgWidth > imgHeight ? 'l' : 'p';

    // Create PDF with appropriate dimensions
    const pdf = new jsPDF({
      orientation,
      unit: 'px',
      format: [imgWidth, imgHeight],
    });

    pdf.addImage(imgData, 'PNG', 0, 0, imgWidth, imgHeight);
    pdf.save(`${filename}.pdf`);

    return { success: true };
  } catch (error) {
    return {
      success: false,
      error: error instanceof Error ? error.message : 'Failed to export PDF'
    };
  }
}

/**
 * Generate a timestamp-based filename
 */
export function generateFilename(prefix: string = 'looksmaxx'): string {
  const date = new Date();
  const timestamp = date.toISOString().split('T')[0];
  return `${prefix}-${timestamp}`;
}

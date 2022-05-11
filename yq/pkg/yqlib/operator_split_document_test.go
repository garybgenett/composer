package yqlib

import (
	"testing"
)

var splitDocOperatorScenarios = []expressionScenario{
	{
		description: "Split empty",
		document:    ``,
		expression:  `split_doc`,
		expected: []string{
			"D0, P[], (!!null)::\n",
		},
	},
	{
		description: "Split array",
		document:    `[{a: cat}, {b: dog}]`,
		expression:  `.[] | split_doc`,
		expected: []string{
			"D0, P[0], (!!map)::{a: cat}\n",
			"D1, P[1], (!!map)::{b: dog}\n",
		},
	},
}

func TestSplitDocOperatorScenarios(t *testing.T) {
	for _, tt := range splitDocOperatorScenarios {
		testScenario(t, &tt)
	}
	documentOperatorScenarios(t, "split-into-documents", splitDocOperatorScenarios)
}

package db

import (
	"fmt"

	"github.com/OpenListTeam/OpenList/v4/internal/conf"
)

func columnName(name string) string {
	if conf.Conf.Database.Type == "postgres" {
		return fmt.Sprintf(`"%s"`, name)
	}
	return fmt.Sprintf("`%s`", name)
}

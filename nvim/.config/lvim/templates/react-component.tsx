import {Theme, withStyles} from '@material-ui/core';
import React from 'react';

const styles = (theme: Theme) => ({
  rootContainer: {
    background: theme.palette.background.paper,
  },
});

interface OwnProps {
  classes: any;
  theme: Theme;
}

type Props = OwnProps;

export const MachineInfo = (props: Props) => {
  return <div>Hellow from InstancesMap</div>;
};

export default withStyles(styles, {withTheme: true})(MachineInfo);
